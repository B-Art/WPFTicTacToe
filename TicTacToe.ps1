Add-Type -AssemblyName PresentationCore, PresentationFramework, WindowsBase, System.Windows.Forms

# Create XAML code
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Tic Tac Toe" Height="600" Width="600">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="100" />
            <RowDefinition Height="3*" />
            <RowDefinition Height="5*" />
        </Grid.RowDefinitions>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="100" />
            <ColumnDefinition Width="3*" />
            <ColumnDefinition Width="5*" />
        </Grid.ColumnDefinitions>
        <Button x:Name="Button00" Grid.Row="0" Grid.Column="0" FontSize="24"/>
        <Button x:Name="Button01" Grid.Row="0" Grid.Column="1" FontSize="24"/>
        <Button x:Name="Button02" Grid.Row="0" Grid.Column="2" FontSize="24"/>
        <Button x:Name="Button03" Grid.Row="1" Grid.Column="0" FontSize="24"/>
        <Button x:Name="Button04" Grid.Row="1" Grid.Column="1" FontSize="24"/>
        <Button x:Name="Button05" Grid.Row="1" Grid.Column="2" FontSize="24"/>
        <Button x:Name="Button06" Grid.Row="2" Grid.Column="0" FontSize="24"/>
        <Button x:Name="Button07" Grid.Row="2" Grid.Column="1" FontSize="24"/>
        <Button x:Name="Button08" Grid.Row="2" Grid.Column="2" FontSize="24"/>
    </Grid>
</Window>
"@

# Function to check for victory
function Test-Victory() {
    [CmdletBinding()]
    Param (
        $icon,
        [ref]$board
    )
    $true -in (
        (0, 1, 2),
        (0, 3, 6),
        (0, 4, 8),
        (1, 4, 7),
        (2, 4, 6),
        (3, 4, 5),
        (2, 5, 8),
        (6, 7, 8)
    ).Foreach{
        $board.Value[$_] -join '' -eq $icon * 3
    }
}

# Function to check for a draw
function Test-Draw() {
    [CmdletBinding()]
    param (
        [ref]$board
    )
    (' ' -notin $board.Value)
}

# Event handler for button click
function Button_Click {
    [CmdletBinding()]
    param ($e,
        [ref]$board,
        [ref]$currentPlayer,
        [ref]$gameOver
    )

    $index = [int]$e.source.Name.Substring(6)
    
    if ($board.Value[$index] -notin ('O', 'X')) {
        $board.Value[$index] = $currentPlayer.Value
        $e.source.Content = $board.Value[$index]
        Write-Host ($e.source.Color)
        $e.source.Background = @{
                "X" = 
                [System.Windows.Media.Brushes].GetProperties().Name.Where{ $_ -like '*Light*Red*' } | get-random;
                "O" = 
                [System.Windows.Media.Brushes].GetProperties().Name.Where{ $_ -like '*Light*Green*' } | get-random 
        }[$currentPlayer.Value]
        if (Test-Victory $currentPlayer.Value $board) {
            [System.Windows.MessageBox]::Show("Player $($currentPlayer.Value) wins!", "Game Over")
            $gameOver.Value = $true
        } elseif (Test-Draw $board) {
            [System.Windows.MessageBox]::Show("It's a draw!", "Game Over")
            $gameOver.Value = $true
        }
        $currentPlayer.Value = if ($currentPlayer.Value -eq 'X') { 'O' } else { 'X' }
        If ($gameOver.Value) {
            $gameOver.Value = $false
            $boardcolors = [System.Windows.Media.Brushes].GetProperties().Name.Where{ $_ -like '*Light*Blue*' } | Get-Random -Count 9   
            for ($i = 0; $i -lt 9; $i++) {
                $button = $window.FindName("Button" + $i.ToString("00"))
                $button.Content, $board.Value[$i] = ' ', ' '
                # [Enum]::GetValues([System.ConsoleColor])
                # [System.Windows.Media.Brushes].GetProperties().Name
                $button.Background = $boardcolors[$i]
            }
        }
    }
}
# Load XAML
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# Initialize game state
$board = @(, ' ' * 9)
$boardcolors = (0..2).Foreach{
    ([System.Windows.Media.Brushes].GetProperties().Name.Where{
        $_ -like '*light*blue*'
    } | Get-Random -Count 9)
}   
$currentPlayer = 'X'
$gameOver = $false

# Add event handlers to buttons
for ($i = 0; $i -lt 9; $i++) {
    $button = $window.FindName("Button" + $i.ToString("00"))
    $button.Add_Click({ Button_Click $_ ([ref]$board) ([ref]$currentPlayer) ([ref]$gameOver) })
    # [System.Windows.Media.Brushes].GetProperties().Name
    $button.Background = $boardcolors[$i]
}

# Show the window
$window.ShowDialog() | Out-Null
