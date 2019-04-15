<# 
Author: Shaun Osborne
Docs: https://github.com/Cybergate9/ZabbixPowershell/blob/master/docs/MaaSScriptsDocumentation.md
#>

#refs:
# https://blogs.technet.microsoft.com/richard_macdonald/2009/04/28/charting-with-powershell/
# and 
# https://learn-powershell.net/2016/09/18/building-a-chart-using-powershell-and-chart-controls/

Param (
    [Parameter(Mandatory=$false,ValueFromPipeline=$True)] [object[]] $input,
    [Parameter(Mandatory=$false)] $Data,
    [Parameter(Mandatory=$false)] $Filename = 'metrics',
    [Parameter(Mandatory=$false)] $ChartTitle = 'Datastores Used & Free Percentages',
    [Parameter(Mandatory=$false)] $ChartWidth = 1000,
    [Parameter(Mandatory=$false)] $ChartHeight = 780,
    [Parameter(Mandatory=$false)] $ChartType = 'StackedBar100',
    [Parameter(Mandatory=$false)] $ChartLabels = 'Values',
    [Parameter(Mandatory=$false)] $ChartLabelsUnits = 'GB',
    [Parameter(Mandatory=$false)] $HostName = 'Hostname',
    [Parameter(Mandatory=$false)] $ToScreen = 'false'
)



# handle input via pipeline if it's there
if($input){
    foreach($i in $input){$data += [object[]]$i}
}
if($Data){
    $data = $Data
}

# if after all that we've gor no data name on command line or in via pipe - we better bail out 
if(-not $data -or -not $data.dsname){
    Write-Output "ERROR: Input Data not present or Invalid"
    exit
}

$count = $data |measure
#$count.count
$ChartHeight = 200 + ($count.count * 45)
#$ChartHeight

# load the appropriate assemblies
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")

$ChartTypes = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]
if($ChartType -eq 'StackedBar100'){ $selectedChartType = $ChartTypes::StackedBar100}
if($ChartType -eq 'StackedBar'){ $selectedChartType = $ChartTypes::StackedBar}
if($ChartType -eq 'Bar'){ $selectedChartType = $ChartTypes::Bar}

if($ChartLabels -eq 'Values'){
    $LabelType = "#VAL" + $ChartLabelsUnits
}
elseif($ChartLabels -eq 'Percent') {
    $ChartLabelsUnits = '%'
    $LabelType = '' + $ChartLabelsUnits
}
# create chart object
$Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
$Chart.Width = $ChartWidth
$Chart.Height = $ChartHeight
$Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title
$TitleFont = New-Object System.Drawing.Font @('Microsoft Sans Serif','13', [System.Drawing.FontStyle]::Bold)
$LabelFont = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)
$BarFont = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Bold)
$cbred = [System.Drawing.ColorTranslator]::FromHtml("#FF1419")
$cbblue = [System.Drawing.ColorTranslator]::FromHtml("#0072F0")

$Title.Text = $ChartTitle
$Title.Font =$TitleFont
$Chart.Titles.Add($Title)

#$Chart.BackColor = [System.Drawing.Color]::Transparent
$chart.Palette = [System.Windows.Forms.DataVisualization.Charting.ChartColorPalette]::None
$chart.PaletteCustomColors = @($cbred, $cbblue)




# create a chartarea to draw on and add to chart
$ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$Chart.ChartAreas.Add($ChartArea)
$ChartArea.AxisX.TitleFont = $LabelFont
$ChartArea.AxisX.Title ="Datastore Name"
$ChartArea.AxisY.TitleFont = $LabelFont
$ChartArea.AxisY.Title ="Percentage"


# add data to chart
[void]$Chart.Series.Add("Used")
[void]$Chart.Series.Add("Free")


$Chart.Series["Used"].ChartType = $selectedChartType
$Chart.Series["Used"]["DrawingStyle"] = "Cylinder"

if($ChartLabelsUnits -eq 'TB'){
    $Chart.Series["Used"].Points.DataBindXY($data.dsname, 'Datastore', $data.usedTB, $data.dsname)     
    $Chart.Series["Used"].AxisLabel = $data.totalTB
    foreach($thing in $Chart.Series["Used"].Points){
        $thing.AxisLabel = $thing.AxisLabel + "\n(" + $data[$x++].totalTB + $ChartLabelsUnits + ")"
           }
  
}
else {
    $Chart.Series["Used"].Points.DataBindXY($data.dsname, 'Datastore', $data.usedGB, $data.dsname) 
    $Chart.Series["Used"].AxisLabel = $data.totalGB
    foreach($thing in $Chart.Series["Used"].Points){
        $thing.AxisLabel = $thing.AxisLabel + "\n(" + $data[$x++].totalGB + $ChartLabelsUnits + ")"
           }
}

#$Chart.Series["Used"].LabelFormat = "{0.00}"
$Chart.Series["Used"].Label = $LabelType
$Chart.Series["Used"].LabelFormat 
$Chart.Series["Used"].LabelForeColor = [System.Drawing.Color]::White
$Chart.Series["Used"].IsValueShownAsLabel = $True
$Chart.Series["Used"].Font = $BarFont



$Chart.Series["Free"].ChartType = $selectedChartType
$Chart.Series["Free"]["DrawingStyle"] = "Cylinder"
if($ChartLabelsUnits -eq 'TB'){
   $Chart.Series["Free"].Points.DataBindXY($data.dsname, 'Percentage', $data.freeTB, $data.dsname) 
}
else {
    $Chart.Series["Free"].Points.DataBindXY($data.dsname, 'Percentage', $data.freeGB, $data.dsname) 
}

$Chart.Series["Free"].IsValueShownAsLabel = $True
#$Chart.Series["Free"].LabelFormat = "{00.00}"
$Chart.Series["Free"].Label = $LabelType
$Chart.Series["Free"].LabelForeColor = [System.Drawing.Color]::White
$Chart.Series["Free"].Font = $BarFont



$Chart.ChartAreas[0].AxisX.LabelStyle.Angle = 0
$Chart.ChartAreas[0].AxisX.LabelStyle.Font = $LabelFont
$Chart.ChartAreas[0].AxisX.Interval = 1

#$Chart.ChartAreas[0].AxisX

$Chart.ChartAreas[0].AxisY.LabelStyle.Angle = -45
$Chart.ChartAreas[0].AxisY.Interval = 10



$Legend = New-Object System.Windows.Forms.DataVisualization.Charting.Legend
$Legend.IsEquallySpacedItems = $True
$Legend.BorderColor = 'Black'
$Legend.Position.Auto = $True
$Legend.Alignment = 'Center'
#$Legend.Position.X = 30;
#$Legend.Position.Y = 100;
#$Legend.DockedToChartArea = $ChartArea[0];

$Legend.Docking = 'Bottom'
$Chart.Legends.Add($Legend)

# Save the chart to file
#Write-Output $path.Path
if($Filename -ne ''){
    $path = pwd
    $Chart.SaveImage($path.Path + '\' + $Hostname + $Filename + '.jpg', 'Jpeg')
}


if($Toscreen -eq 'true')
  {
    <# display the chart on a form #>
    $Chart.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor
                    [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
    $Form = New-Object Windows.Forms.Form
    $Form.Text = "PowerShell Chart"
    $Form.Width = 1300
    $Form.Height = $ChartHeight + 200
    $Form.AutoScroll=$True
    $Form.controls.add($Chart)
    $Form.Add_Shown({$Form.Activate()})
    $Form.ShowDialog() 
   }