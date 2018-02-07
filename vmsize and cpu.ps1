#Script that will query your Azure VM's and return sizes and average CPU usage over the last 7 days..


#Login-AzureRmAccount

$vms = Get-AzureRmVM | select * 

$Allobjs = @()

$hwtotal = get-azurermvmsize -location westeurope  

foreach ($vm in $vms) {

$obj = new-object psobject

$hw = $hwtotal | Where-Object{ $_.name -eq $vm.HardwareProfile.vmsize }

Add-Member -InputObject $obj -MemberType NoteProperty -Name ResourceGroupName -Value $vm.ResourceGroupName
Add-Member -InputObject $obj -MemberType NoteProperty -Name Name -Value $vm.Name
Add-Member -InputObject $obj -MemberType NoteProperty -Name vmsize -Value $vm.HardwareProfile.vmsize
Add-Member -InputObject $obj -MemberType NoteProperty -Name Location -Value $vm.Location

Add-Member -InputObject $obj -MemberType NoteProperty -Name NumberOfCores -Value $hw.NumberOfCores
Add-Member -InputObject $obj -MemberType NoteProperty -Name MemoryInMB -Value $hw.MemoryInMB

$start = [datetime](get-date).AddDays(-7)

$perf = Get-AzureRmMetric -ResourceId $vm.Id -TimeGrain 24:00:00  -MetricNames "Percentage CPU" -StartTime $start -AggregationType Average

Add-Member -InputObject $obj -MemberType NoteProperty -Name PercentageCPUAvg -Value $perf.Data.average
$Allobjs = $Allobjs + $obj


}

$Allobjs | ft  #|Export-Csv -Path c:\somepath\VMlist.csv

