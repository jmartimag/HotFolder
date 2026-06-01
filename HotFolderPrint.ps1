#Requires -Version 5.1
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

# ── Icono embebido en Base64 (impresora 16x16) ───────────────
$iconBase64 = @"
AAABAAEAEBAQAAEABAAoAQAAFgAAACgAAAAQAAAAIAAAAAEABAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAiIiIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA////
/////wAAAAD/////AAAAAAAAAAD/////AAAAAAAAAAD///////////8AAAAA//////////8AAAAAAAAA
AP///////////wAAAAD//////////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA//////////8A
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
"@
# Crear icono desde los recursos del sistema (shell32) — más fiable que base64 raw
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public class NativeIcon {
    [DllImport("shell32.dll", CharSet=CharSet.Auto)]
    public static extern IntPtr ExtractIcon(IntPtr hInst, string lpszExeFileName, int nIconIndex);
}
'@ -ErrorAction SilentlyContinue

function Get-AppIcon {
    try {
        $hIcon = [NativeIcon]::ExtractIcon([IntPtr]::Zero, "$env:SystemRoot\System32\shell32.dll", 17)
        if ($hIcon -ne [IntPtr]::Zero) {
            return [System.Drawing.Icon]::FromHandle($hIcon)
        }
    } catch {}
    return [System.Drawing.SystemIcons]::Application
}

[xml]$XAML = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Hot Folder Print Monitor"
    Height="820" Width="1080"
    MinHeight="700" MinWidth="900"
    WindowStartupLocation="CenterScreen"
    Background="#0F0F13"
    ShowInTaskbar="True">

    <Window.Resources>

        <!-- Boton primario -->
        <Style x:Key="BtnPrimary" TargetType="Button">
            <Setter Property="Background"      Value="#3B82F6"/>
            <Setter Property="Foreground"      Value="White"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Padding"         Value="16,9"/>
            <Setter Property="FontSize"        Value="13"/>
            <Setter Property="Cursor"          Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="bd" Background="{TemplateBinding Background}"
                                CornerRadius="8" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="bd" Property="Background" Value="#2563EB"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="bd" Property="Background" Value="#1D4ED8"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="bd" Property="Background" Value="#374151"/>
                                <Setter Property="Foreground" Value="#6B7280"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="BtnDanger" TargetType="Button" BasedOn="{StaticResource BtnPrimary}">
            <Setter Property="Background" Value="#EF4444"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#DC2626"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <Style x:Key="BtnNeutral" TargetType="Button" BasedOn="{StaticResource BtnPrimary}">
            <Setter Property="Background" Value="#2D2D3D"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#374151"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <Style x:Key="BtnSmall" TargetType="Button" BasedOn="{StaticResource BtnNeutral}">
            <Setter Property="Padding"   Value="10,5"/>
            <Setter Property="FontSize"  Value="11"/>
        </Style>

        <!-- TextBox oscuro -->
        <Style x:Key="DarkInput" TargetType="TextBox">
            <Setter Property="Background"      Value="#1A1A22"/>
            <Setter Property="Foreground"      Value="#F1F5F9"/>
            <Setter Property="BorderBrush"     Value="#2D2D3D"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding"         Value="10,8"/>
            <Setter Property="FontSize"        Value="13"/>
            <Setter Property="Height"          Value="34"/>
            <Setter Property="CaretBrush"      Value="#3B82F6"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TextBox">
                        <Border Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="8">
                            <ScrollViewer x:Name="PART_ContentHost" Margin="2,0"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- ComboBox legible -->
        <Style x:Key="DarkCombo" TargetType="ComboBox">
            <Setter Property="Background"        Value="White"/>
            <Setter Property="Foreground"        Value="#111111"/>
            <Setter Property="BorderBrush"       Value="#2D2D3D"/>
            <Setter Property="BorderThickness"   Value="1"/>
            <Setter Property="FontSize"          Value="12"/>
            <Setter Property="Height"            Value="34"/>
            <Setter Property="Padding"           Value="8,4"/>
            <Setter Property="ItemContainerStyle">
                <Setter.Value>
                    <Style TargetType="ComboBoxItem">
                        <Setter Property="Foreground"  Value="#111111"/>
                        <Setter Property="Background"  Value="White"/>
                        <Setter Property="Padding"     Value="8,5"/>
                        <Style.Triggers>
                            <Trigger Property="IsHighlighted" Value="True">
                                <Setter Property="Background" Value="#DBEAFE"/>
                                <Setter Property="Foreground" Value="#1E3A8A"/>
                            </Trigger>
                        </Style.Triggers>
                    </Style>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- RadioButton oscuro -->
        <Style x:Key="DarkRadio" TargetType="RadioButton">
            <Setter Property="Foreground"   Value="#CBD5E1"/>
            <Setter Property="FontSize"     Value="12"/>
            <Setter Property="Cursor"       Value="Hand"/>
            <Setter Property="Margin"       Value="0,0,12,0"/>
        </Style>

        <!-- CheckBox oscuro -->
        <Style x:Key="DarkCheck" TargetType="CheckBox">
            <Setter Property="Foreground"   Value="#CBD5E1"/>
            <Setter Property="FontSize"     Value="12"/>
            <Setter Property="Cursor"       Value="Hand"/>
        </Style>

        <!-- ListView -->
        <Style TargetType="ListView">
            <Setter Property="Background"      Value="Transparent"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Foreground"      Value="#F1F5F9"/>
            <Setter Property="FontSize"        Value="12"/>
        </Style>
        <Style TargetType="ListViewItem">
            <Setter Property="Background"      Value="Transparent"/>
            <Setter Property="Foreground"      Value="#F1F5F9"/>
            <Setter Property="Padding"         Value="6,4"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#22222E"/>
                </Trigger>
                <Trigger Property="IsSelected" Value="True">
                    <Setter Property="Background" Value="#1E3A5F"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <!-- GroupBox oscuro -->
        <Style x:Key="DarkGroup" TargetType="GroupBox">
            <Setter Property="Foreground"      Value="#94A3B8"/>
            <Setter Property="FontSize"        Value="11"/>
            <Setter Property="FontWeight"      Value="SemiBold"/>
            <Setter Property="BorderBrush"     Value="#2D2D3D"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding"         Value="8,6"/>
            <Setter Property="Margin"          Value="0,0,0,0"/>
        </Style>

    </Window.Resources>

    <Grid Margin="16">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- HEADER -->
        <StackPanel Grid.Row="0" Margin="0,0,0,12">
            <TextBlock Text="Hot Folder Print Monitor"
                       Foreground="#F1F5F9" FontSize="20" FontWeight="SemiBold"/>
            <TextBlock Text="Monitorea una carpeta e imprime automaticamente los archivos que lleguen"
                       Foreground="#64748B" FontSize="12" Margin="0,4,0,0"/>
        </StackPanel>

        <!-- CARPETA -->
        <Border Grid.Row="1" Background="#1A1A22" CornerRadius="10"
                BorderBrush="#2D2D3D" BorderThickness="1" Padding="14" Margin="0,0,0,8">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="14"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="8"/>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="14"/>
                    <ColumnDefinition Width="120"/>
                </Grid.ColumnDefinitions>
                <StackPanel Grid.Column="0" VerticalAlignment="Center">
                    <TextBlock Text="CARPETA A MONITOREAR" Foreground="#64748B"
                               FontSize="10" FontWeight="SemiBold" Margin="0,0,0,6"/>
                    <TextBlock Text="Impresora" Foreground="#64748B"
                               FontSize="10" FontWeight="SemiBold" Margin="0,6,0,6"/>
                </StackPanel>
                <StackPanel Grid.Column="2">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="8"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <TextBox x:Name="txtHotFolder" Grid.Column="0"
                                 Style="{StaticResource DarkInput}" Text="C:\HotFolder"/>
                        <Button x:Name="btnBrowse" Grid.Column="2" Content="Examinar..."
                                Style="{StaticResource BtnNeutral}" Height="34" Padding="12,5"/>
                    </Grid>
                    <ComboBox x:Name="cboPrinter" Style="{StaticResource DarkCombo}" Margin="0,6,0,0"/>
                </StackPanel>
                <StackPanel Grid.Column="4" VerticalAlignment="Center">
                    <TextBlock Text=" " FontSize="10" Margin="0,0,0,6"/>
                    <TextBlock Text="Copias" Foreground="#64748B"
                               FontSize="10" FontWeight="SemiBold" Margin="0,6,0,6"/>
                </StackPanel>
                <StackPanel Grid.Column="6">
                    <TextBlock Text=" " FontSize="10" Margin="0,0,0,6"/>
                    <TextBox x:Name="txtCopies" Style="{StaticResource DarkInput}" Text="1" Margin="0,6,0,0"/>
                </StackPanel>
            </Grid>
        </Border>

        <!-- CONFIGURACION DE CAJONES -->
        <Border Grid.Row="2" Background="#1A1A22" CornerRadius="10"
                BorderBrush="#2D2D3D" BorderThickness="1" Padding="14" Margin="0,0,0,8">
            <StackPanel>
                <TextBlock Text="CONFIGURACION POR CAJON / BANDEJA" Foreground="#64748B"
                           FontSize="10" FontWeight="SemiBold" Margin="0,0,0,10"/>
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="220"/>
                        <ColumnDefinition Width="12"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>

                    <!-- Lista de cajones -->
                    <Border Grid.Column="0" Background="#13131A" CornerRadius="8"
                            BorderBrush="#2D2D3D" BorderThickness="1">
                        <StackPanel>
                            <Border Background="#1E1E2E" CornerRadius="8,8,0,0" Padding="10,8">
                                <TextBlock Text="Cajones disponibles" Foreground="#94A3B8"
                                           FontSize="11" FontWeight="SemiBold"/>
                            </Border>
                            <ListBox x:Name="lstBins" Background="Transparent"
                                     BorderThickness="0" Foreground="#F1F5F9"
                                     FontSize="12" Padding="4" MinHeight="140">
                                <ListBox.ItemContainerStyle>
                                    <Style TargetType="ListBoxItem">
                                        <Setter Property="Foreground" Value="#CBD5E1"/>
                                        <Setter Property="Padding"    Value="8,6"/>
                                        <Setter Property="Cursor"     Value="Hand"/>
                                        <Style.Triggers>
                                            <Trigger Property="IsMouseOver" Value="True">
                                                <Setter Property="Background" Value="#22222E"/>
                                            </Trigger>
                                            <Trigger Property="IsSelected"   Value="True">
                                                <Setter Property="Background" Value="#1E3A5F"/>
                                                <Setter Property="Foreground" Value="White"/>
                                            </Trigger>
                                        </Style.Triggers>
                                    </Style>
                                </ListBox.ItemContainerStyle>
                            </ListBox>
                        </StackPanel>
                    </Border>

                    <!-- Panel de configuracion del cajon seleccionado -->
                    <Border Grid.Column="2" Background="#13131A" CornerRadius="8"
                            BorderBrush="#2D2D3D" BorderThickness="1" Padding="14">
                        <StackPanel x:Name="panelBinConfig">
                            <TextBlock x:Name="lblBinTitle" Text="Selecciona un cajon para configurarlo"
                                       Foreground="#64748B" FontSize="12" Margin="0,0,0,12"/>
                            <Grid x:Name="gridBinOptions" IsEnabled="False">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="12"/>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="12"/>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="12"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>

                                <!-- TAMANO DE PAGINA -->
                                <GroupBox Grid.Column="0" Header="Tamaño de papel" Style="{StaticResource DarkGroup}">
                                    <StackPanel Margin="0,6,0,0">
                                        <RadioButton x:Name="rdoA4"  Content="A4"  Style="{StaticResource DarkRadio}" GroupName="PaperSize" IsChecked="True" Margin="0,0,0,4"/>
                                        <RadioButton x:Name="rdoA3"  Content="A3"  Style="{StaticResource DarkRadio}" GroupName="PaperSize" Margin="0,0,0,4"/>
                                        <RadioButton x:Name="rdoA5"  Content="A5"  Style="{StaticResource DarkRadio}" GroupName="PaperSize" Margin="0,0,0,4"/>
                                        <RadioButton x:Name="rdoLetter" Content="Letter" Style="{StaticResource DarkRadio}" GroupName="PaperSize"/>
                                    </StackPanel>
                                </GroupBox>

                                <!-- ORIENTACION -->
                                <GroupBox Grid.Column="2" Header="Orientacion" Style="{StaticResource DarkGroup}">
                                    <StackPanel Margin="0,6,0,0">
                                        <RadioButton x:Name="rdoPortrait"  Content="Vertical"    Style="{StaticResource DarkRadio}" GroupName="Orient" IsChecked="True" Margin="0,0,0,4"/>
                                        <RadioButton x:Name="rdoLandscape" Content="Horizontal"  Style="{StaticResource DarkRadio}" GroupName="Orient"/>
                                    </StackPanel>
                                </GroupBox>

                                <!-- CARAS -->
                                <GroupBox Grid.Column="4" Header="Impresion" Style="{StaticResource DarkGroup}">
                                    <StackPanel Margin="0,6,0,0">
                                        <RadioButton x:Name="rdoSimplex"  Content="Una cara"    Style="{StaticResource DarkRadio}" GroupName="Duplex" IsChecked="True" Margin="0,0,0,4"/>
                                        <RadioButton x:Name="rdoDuplex"   Content="Doble cara"  Style="{StaticResource DarkRadio}" GroupName="Duplex" Margin="0,0,0,4"/>
                                        <RadioButton x:Name="rdoDuplexTumble" Content="Doble cara (horizontal)" Style="{StaticResource DarkRadio}" GroupName="Duplex"/>
                                    </StackPanel>
                                </GroupBox>

                                <!-- COLOR -->
                                <GroupBox Grid.Column="6" Header="Color" Style="{StaticResource DarkGroup}">
                                    <StackPanel Margin="0,6,0,0">
                                        <RadioButton x:Name="rdoColor" Content="Color"       Style="{StaticResource DarkRadio}" GroupName="ColorMode" IsChecked="True" Margin="0,0,0,4"/>
                                        <RadioButton x:Name="rdoBW"    Content="B/N"         Style="{StaticResource DarkRadio}" GroupName="ColorMode"/>
                                    </StackPanel>
                                </GroupBox>
                            </Grid>

                            <!-- Boton guardar config de cajon -->
                            <StackPanel Orientation="Horizontal" Margin="0,12,0,0" HorizontalAlignment="Right">
                                <TextBlock x:Name="lblBinSaved" Text="" Foreground="#22C55E"
                                           FontSize="11" VerticalAlignment="Center" Margin="0,0,10,0"/>
                                <Button x:Name="btnSaveBinConfig" Content="Guardar configuracion del cajon"
                                        Style="{StaticResource BtnPrimary}" Padding="14,7" FontSize="12"
                                        IsEnabled="False"/>
                            </StackPanel>
                        </StackPanel>
                    </Border>
                </Grid>
            </StackPanel>
        </Border>

        <!-- CONTROLES -->
        <Border Grid.Row="3" Background="#1A1A22" CornerRadius="10"
                BorderBrush="#2D2D3D" BorderThickness="1" Padding="14" Margin="0,0,0,8">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <Button x:Name="btnStart" Grid.Column="0" Content="Iniciar Monitor"
                        Style="{StaticResource BtnPrimary}" MinWidth="150" Margin="0,0,8,0"/>
                <Button x:Name="btnStop" Grid.Column="1" Content="Detener"
                        Style="{StaticResource BtnDanger}" MinWidth="110"
                        IsEnabled="False" Margin="0,0,8,0"/>
                <Button x:Name="btnTestPrint" Grid.Column="2" Content="Pagina de prueba"
                        Style="{StaticResource BtnNeutral}" MinWidth="140" Margin="0,0,8,0"/>
                <CheckBox x:Name="chkDeleteAfterPrint" Grid.Column="3"
                          Content="Eliminar al imprimir" IsChecked="False"
                          Foreground="#94A3B8" VerticalAlignment="Center"
                          Margin="12,0,0,0" ToolTip="Si esta marcado, el archivo se elimina tras imprimirse. Si no, se mueve a la carpeta /Impreso."/>
                <StackPanel Grid.Column="5" Orientation="Horizontal"
                            VerticalAlignment="Center" Margin="0,0,12,0">
                    <Ellipse x:Name="statusDot" Width="10" Height="10"
                             Fill="#374151" VerticalAlignment="Center" Margin="0,0,6,0"/>
                    <TextBlock x:Name="lblStatus" Text="Detenido"
                               Foreground="#64748B" FontSize="12" VerticalAlignment="Center"/>
                </StackPanel>
                <Button x:Name="btnClearLog" Grid.Column="6" Content="Limpiar log"
                        Style="{StaticResource BtnNeutral}" MinWidth="100"/>
            </Grid>
        </Border>

        <!-- LOG -->
        <Border Grid.Row="4" Background="#1A1A22" CornerRadius="10"
                BorderBrush="#2D2D3D" BorderThickness="1" Margin="0,0,0,8">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>
                <Border Grid.Row="0" Background="#13131A" CornerRadius="10,10,0,0" Padding="14,8">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <TextBlock Text="REGISTRO DE ACTIVIDAD" Foreground="#64748B"
                                   FontSize="10" FontWeight="SemiBold" VerticalAlignment="Center"/>
                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                            <TextBlock Text="Archivos procesados: " Foreground="#64748B"
                                       FontSize="12" VerticalAlignment="Center"/>
                            <TextBlock x:Name="lblCount" Text="0" Foreground="#3B82F6"
                                       FontSize="12" FontWeight="SemiBold" VerticalAlignment="Center"/>
                        </StackPanel>
                    </Grid>
                </Border>
                <ListView x:Name="lstLog" Grid.Row="1" Padding="6"
                          ScrollViewer.VerticalScrollBarVisibility="Auto">
                    <ListView.View>
                        <GridView>
                            <GridViewColumn Header="Hora"       Width="75"
                                            DisplayMemberBinding="{Binding Time}"/>
                            <GridViewColumn Header="Evento"     Width="100"
                                            DisplayMemberBinding="{Binding Event}"/>
                            <GridViewColumn Header="Archivo"    Width="220"
                                            DisplayMemberBinding="{Binding File}"/>
                            <GridViewColumn Header="Impresora / Bandeja" Width="180"
                                            DisplayMemberBinding="{Binding Printer}"/>
                            <GridViewColumn Header="Config"     Width="200"
                                            DisplayMemberBinding="{Binding Config}"/>
                            <GridViewColumn Header="Estado"     Width="130"
                                            DisplayMemberBinding="{Binding Status}"/>
                        </GridView>
                    </ListView.View>
                </ListView>
            </Grid>
        </Border>

        <!-- STATUS BAR -->
        <Border Grid.Row="5" Background="#13131A" CornerRadius="8"
                Padding="12,6" BorderBrush="#2D2D3D" BorderThickness="1">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <TextBlock x:Name="lblStatusBar"
                           Text="Listo. Configura la carpeta, selecciona impresora y presiona Iniciar."
                           Foreground="#64748B" FontSize="11" VerticalAlignment="Center"/>
                <TextBlock Grid.Column="1" Text="Copyright Jonatan T35 v2.1"
                           Foreground="#374151" FontSize="10" VerticalAlignment="Center"/>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

# ── Cargar ventana ───────────────────────────────────────────
$reader = [System.Xml.XmlNodeReader]::new($XAML)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Controles principales
$txtHotFolder    = $window.FindName("txtHotFolder")
$btnBrowse       = $window.FindName("btnBrowse")
$cboPrinter      = $window.FindName("cboPrinter")
$txtCopies       = $window.FindName("txtCopies")
$btnStart        = $window.FindName("btnStart")
$btnStop         = $window.FindName("btnStop")
$btnTestPrint    = $window.FindName("btnTestPrint")
$btnClearLog     = $window.FindName("btnClearLog")
$chkDelete       = $window.FindName("chkDeleteAfterPrint")
$lstLog          = $window.FindName("lstLog")
$lblStatus       = $window.FindName("lblStatus")
$statusDot       = $window.FindName("statusDot")
$lblStatusBar    = $window.FindName("lblStatusBar")
$lblCount        = $window.FindName("lblCount")

# Controles de cajones
$lstBins         = $window.FindName("lstBins")
$gridBinOptions  = $window.FindName("gridBinOptions")
$lblBinTitle     = $window.FindName("lblBinTitle")
$btnSaveBinConfig= $window.FindName("btnSaveBinConfig")
$lblBinSaved     = $window.FindName("lblBinSaved")

# Radio buttons de configuracion de cajon
$rdoA4           = $window.FindName("rdoA4")
$rdoA3           = $window.FindName("rdoA3")
$rdoA5           = $window.FindName("rdoA5")
$rdoLetter       = $window.FindName("rdoLetter")
$rdoPortrait     = $window.FindName("rdoPortrait")
$rdoLandscape    = $window.FindName("rdoLandscape")
$rdoSimplex      = $window.FindName("rdoSimplex")
$rdoDuplex       = $window.FindName("rdoDuplex")
$rdoDuplexTumble = $window.FindName("rdoDuplexTumble")
$rdoColor        = $window.FindName("rdoColor")
$rdoBW           = $window.FindName("rdoBW")

# ── Estado global ────────────────────────────────────────────
$script:watcherTimer     = $null
$script:fileCount        = 0
$script:activePrinter    = ""
$script:activeCopies     = 1
$script:watchFolder      = ""
$script:seenFiles        = $null
$script:deleteAfterPrint = $false
$script:printJobs        = [System.Collections.Generic.List[object]]::new()
$script:savedMsgTimer    = $null
$script:activeBinCfg     = $null

# Diccionario: clave = Label del cajon, valor = hashtable de configuracion
# Cada cajon tiene: PaperSize, Landscape, Duplex, Color, BinCode
$script:binConfigs       = @{}

# Lista de items de cajon (PSCustomObject con Label, Code)
$script:binItems         = [System.Collections.Generic.List[object]]::new()

# Cajon actualmente seleccionado en la UI (para guardar config)
$script:selectedBinKey   = $null

# ── Helpers UI ───────────────────────────────────────────────
function Add-LogEntry {
    param($Event, $File, $Printer, $Config, $Status)
    $entry = [PSCustomObject]@{
        Time    = (Get-Date -Format "HH:mm:ss")
        Event   = $Event
        File    = $File
        Printer = $Printer
        Config  = $Config
        Status  = $Status
    }
    $lstLog.Items.Add($entry)
    $lstLog.ScrollIntoView($entry)
    $script:fileCount++
    $lblCount.Text = $script:fileCount.ToString()
}

function Set-StatusBar { param($msg) $lblStatusBar.Text = $msg }

function Set-MonitorState { param([bool]$running)
    if ($running) {
        $statusDot.Fill         = [System.Windows.Media.Brushes]::LimeGreen
        $lblStatus.Text         = "Monitoreando"
        $lblStatus.Foreground   = [System.Windows.Media.Brushes]::LimeGreen
        $btnStart.IsEnabled     = $false
        $btnStop.IsEnabled      = $true
        $txtHotFolder.IsEnabled = $false
        $cboPrinter.IsEnabled   = $false
        $lstBins.IsEnabled      = $false
        $gridBinOptions.IsEnabled = $false
        $btnSaveBinConfig.IsEnabled = $false
    } else {
        $statusDot.Fill         = [System.Windows.Media.Brushes]::DimGray
        $lblStatus.Text         = "Detenido"
        $lblStatus.Foreground   = [System.Windows.Media.Brushes]::Gray
        $btnStart.IsEnabled     = $true
        $btnStop.IsEnabled      = $false
        $txtHotFolder.IsEnabled = $true
        $cboPrinter.IsEnabled   = $true
        $lstBins.IsEnabled      = $true
    }
}

# Devuelve el config del cajon activo en la UI
function Get-CurrentBinConfig {
    $paper = if($rdoA4.IsChecked){"A4"} elseif($rdoA3.IsChecked){"A3"} elseif($rdoA5.IsChecked){"A5"} else{"Letter"}
    $duplex= if($rdoDuplex.IsChecked){"Duplex"} elseif($rdoDuplexTumble.IsChecked){"DuplexTumble"} else{"Simplex"}
    return @{
        PaperSize = $paper
        Landscape = ($rdoLandscape.IsChecked -eq $true)
        Duplex    = $duplex
        Color     = ($rdoColor.IsChecked -eq $true)
    }
}

# Aplica un hashtable de config a los radio buttons
function Set-BinConfigUI { param($cfg)
    switch($cfg.PaperSize){
        "A3"     { $rdoA3.IsChecked=$true }
        "A5"     { $rdoA5.IsChecked=$true }
        "Letter" { $rdoLetter.IsChecked=$true }
        default  { $rdoA4.IsChecked=$true }
    }
    $rdoLandscape.IsChecked = ($cfg.Landscape -eq $true)
    $rdoPortrait.IsChecked  = ($cfg.Landscape -ne $true)
    switch($cfg.Duplex){
        "Duplex"       { $rdoDuplex.IsChecked=$true }
        "DuplexTumble" { $rdoDuplexTumble.IsChecked=$true }
        default        { $rdoSimplex.IsChecked=$true }
    }
    $rdoColor.IsChecked = ($cfg.Color -ne $false)
    $rdoBW.IsChecked    = ($cfg.Color -eq $false)
}

# Genera etiqueta legible de config para el log
function Get-ConfigLabel { param($cfg)
    $paper = $cfg.PaperSize
    $ori   = if($cfg.Landscape){"Horiz"}else{"Vert"}
    $dup   = switch($cfg.Duplex){"Duplex"{"2C"};"DuplexTumble"{"2C-H"};default{"1C"}}
    $col   = if($cfg.Color){"Color"}else{"B/N"}
    return "$paper $ori $dup $col"
}

# ── Cargar impresoras ────────────────────────────────────────
function Load-Printers {
    $cboPrinter.Items.Clear()
    try { $printers = Get-Printer -ErrorAction Stop | Select-Object -ExpandProperty Name }
    catch { $printers = Get-WmiObject -Query "SELECT Name FROM Win32_Printer" | Select-Object -ExpandProperty Name }
    foreach ($p in $printers) { [void]$cboPrinter.Items.Add($p) }
    $def = (Get-WmiObject -Query "SELECT Name FROM Win32_Printer WHERE Default=True" | Select-Object -First 1).Name
    if ($def -and $cboPrinter.Items.Contains($def)) { $cboPrinter.SelectedItem = $def }
    elseif ($cboPrinter.Items.Count -gt 0)          { $cboPrinter.SelectedIndex = 0 }
}

# ── Cargar cajones en la lista lateral ──────────────────────
function Load-PaperBins { param($PrinterName)
    $lstBins.Items.Clear()
    $script:binItems.Clear()
    $script:binConfigs = @{}
    $script:selectedBinKey = $null
    $gridBinOptions.IsEnabled = $false
    $btnSaveBinConfig.IsEnabled = $false
    $lblBinTitle.Text = "Selecciona un cajon para configurarlo"
    $lblBinSaved.Text = ""
    $added = $false

    try {
        $pd = New-Object System.Drawing.Printing.PrintDocument
        $pd.PrinterSettings.PrinterName = $PrinterName
        foreach ($src in $pd.PrinterSettings.PaperSources) {
            $item = [PSCustomObject]@{ Label=$src.SourceName; Code=[int]$src.RawKind }
            $script:binItems.Add($item)
            [void]$lstBins.Items.Add($src.SourceName)
            # Config por defecto para cada cajon
            $script:binConfigs[$src.SourceName] = @{
                PaperSize="A4"; Landscape=$false; Duplex="Simplex"; Color=$true; BinCode=[int]$src.RawKind
            }
            $added = $true
        }
        $pd.Dispose()
    } catch {}

    if (-not $added) {
        $defaults = @(
            [PSCustomObject]@{Label="Seleccion automatica";Code=7},
            [PSCustomObject]@{Label="Bandeja multiuso";Code=4},
            [PSCustomObject]@{Label="Casete 1";Code=1},
            [PSCustomObject]@{Label="Casete 2";Code=3},
            [PSCustomObject]@{Label="Casete 3";Code=2}
        )
        foreach ($b in $defaults) {
            $script:binItems.Add($b)
            [void]$lstBins.Items.Add($b.Label)
            $script:binConfigs[$b.Label] = @{
                PaperSize="A4"; Landscape=$false; Duplex="Simplex"; Color=$true; BinCode=$b.Code
            }
        }
    }

    if ($lstBins.Items.Count -gt 0) { $lstBins.SelectedIndex = 0 }
}

# ── Script de impresion (Start-Job) ─────────────────────────
$script:printScript = {
    param($FilePath, $PrinterName, $BinCode, $Copies, $DeleteAfterPrint,
          $PaperSize, $Landscape, $Duplex, $ColorMode)
    Add-Type -AssemblyName System.Drawing
    # Reconvertir desde int (los bool no sobreviven Start-Job serializacion)
    [bool]$DeleteAfterPrint = [int]$DeleteAfterPrint
    [bool]$Landscape        = [int]$Landscape
    [bool]$ColorMode        = [int]$ColorMode

    function Apply-PrintSettings {
        param($pd, [int]$BinCode, [string]$PaperSize, [bool]$Landscape,
              [string]$Duplex, [bool]$ColorMode)

        # Bandeja
        if ($BinCode -gt 0) {
            $src = $pd.PrinterSettings.PaperSources |
                   Where-Object { $_.RawKind -eq $BinCode } |
                   Select-Object -First 1
            if ($src) { $pd.DefaultPageSettings.PaperSource = $src }
        }

        # Tamaño de papel
        $paperMap = @{ A4=9; A3=8; A5=11; Letter=1 }
        $targetKind = $paperMap[$PaperSize]
        if ($targetKind) {
            $ps = $pd.PrinterSettings.PaperSizes |
                  Where-Object { $_.RawKind -eq $targetKind } |
                  Select-Object -First 1
            if (-not $ps) {
                # Buscar por nombre si no hay RawKind exacto
                $ps = $pd.PrinterSettings.PaperSizes |
                      Where-Object { $_.PaperName -like "*$PaperSize*" } |
                      Select-Object -First 1
            }
            if ($ps) { $pd.DefaultPageSettings.PaperSize = $ps }
        }

        # Orientacion
        $pd.DefaultPageSettings.Landscape = $Landscape

        # Duplex (via PrinterSettings si el driver lo soporta)
        try {
            switch ($Duplex) {
                "Duplex"       { $pd.PrinterSettings.Duplex = [Drawing.Printing.Duplex]::Default }
                "DuplexTumble" { $pd.PrinterSettings.Duplex = [Drawing.Printing.Duplex]::Horizontal }
                default        { $pd.PrinterSettings.Duplex = [Drawing.Printing.Duplex]::Simplex }
            }
        } catch {}

        # Color (solo si el driver soporta color)
        try {
            $pd.DefaultPageSettings.Color = $ColorMode
        } catch {}
    }

    # Esperar a que el archivo este disponible (max 30s)
    $ok = $false
    for($i=0;$i -lt 60;$i++){
        try{$fs=[IO.File]::Open($FilePath,'Open','ReadWrite','None');$fs.Close();$fs.Dispose();$ok=$true;break}
        catch{Start-Sleep -Milliseconds 500}
    }
    if(-not $ok){throw "Archivo bloqueado o inaccesible"}

    $ext = [IO.Path]::GetExtension($FilePath).ToLower()

    switch -Regex ($ext) {
        '\.pdf' {
            $s = @("$env:ProgramFiles\SumatraPDF\SumatraPDF.exe",
                   "${env:ProgramFiles(x86)}\SumatraPDF\SumatraPDF.exe",
                   "$env:LOCALAPPDATA\SumatraPDF\SumatraPDF.exe") |
                 Where-Object{Test-Path $_} | Select-Object -First 1
            if($s){
                $printSettings = "copies=$Copies"
                if($BinCode -gt 0){ $printSettings += ",bin=$BinCode" }
                if($Duplex -eq "Duplex")       { $printSettings += ",duplex" }
                if($Duplex -eq "DuplexTumble") { $printSettings += ",duplextumble" }
                if($Landscape)                 { $printSettings += ",landscape" }
                if(-not $ColorMode)            { $printSettings += ",monochrome" }
                $p = Start-Process $s -ArgumentList "-print-to `"$PrinterName`" -print-settings `"$printSettings`" -silent `"$FilePath`"" -Wait -WindowStyle Hidden -PassThru
            } else {
                $psi=New-Object Diagnostics.ProcessStartInfo
                $psi.FileName=$FilePath;$psi.Verb="printto"
                $psi.Arguments="`"$PrinterName`""
                $psi.UseShellExecute=$true
                $psi.WindowStyle=[Diagnostics.ProcessWindowStyle]::Hidden
                $p=[Diagnostics.Process]::Start($psi)
                if($p){$p.WaitForExit(30000);if(-not $p.HasExited){$p.Kill()}}
            }
        }
        '\.(txt|log|csv)' {
            $pd=New-Object Drawing.Printing.PrintDocument
            $pd.PrinterSettings.PrinterName=$PrinterName
            $pd.PrinterSettings.Copies=[int16]$Copies
            Apply-PrintSettings -pd $pd -BinCode $BinCode -PaperSize $PaperSize `
                -Landscape $Landscape -Duplex $Duplex -ColorMode $ColorMode
            $lines=[IO.File]::ReadAllLines($FilePath);$li=0
            $font=New-Object Drawing.Font("Courier New",9)
            $pd.add_PrintPage({param($s,$ev)
                $y=$ev.MarginBounds.Top
                while($li -lt $lines.Count){
                    $ev.Graphics.DrawString($lines[$li],$font,[Drawing.Brushes]::Black,$ev.MarginBounds.Left,$y)
                    $y+=$font.GetHeight($ev.Graphics);$li++
                    if($y+$font.GetHeight($ev.Graphics) -gt $ev.MarginBounds.Bottom){$ev.HasMorePages=($li -lt $lines.Count);break}
                }
            })
            $pd.Print();$font.Dispose();$pd.Dispose()
        }
        '\.(jpe?g|png|bmp|gif|tiff?)' {
            $pd=New-Object Drawing.Printing.PrintDocument
            $pd.PrinterSettings.PrinterName=$PrinterName
            $pd.PrinterSettings.Copies=[int16]$Copies
            Apply-PrintSettings -pd $pd -BinCode $BinCode -PaperSize $PaperSize `
                -Landscape $Landscape -Duplex $Duplex -ColorMode $ColorMode
            $img=[Drawing.Image]::FromFile($FilePath)
            $pd.add_PrintPage({param($s,$ev)
                # VisibleClipBounds ya esta en las mismas unidades que Graphics (pixeles a la resolucion real)
                $b=$ev.Graphics.VisibleClipBounds
                $imgW=$img.Width; $imgH=$img.Height
                $pageW=$b.Width;  $pageH=$b.Height
                # Auto-rotar: si la imagen es apaisada y la pagina es vertical (o viceversa), girar 90 grados
                if(($imgW -gt $imgH -and $pageW -lt $pageH) -or ($imgW -lt $imgH -and $pageW -gt $pageH)){
                    $img.RotateFlip([Drawing.RotateFlipType]::Rotate90FlipNone)
                    $imgW=$img.Width; $imgH=$img.Height
                }
                # Escalar manteniendo proporcion, ajustando al maximo sin recortar
                $r=[Math]::Min([double]$pageW/[double]$imgW,[double]$pageH/[double]$imgH)
                $drawW=[int]($imgW*$r); $drawH=[int]($imgH*$r)
                $x=[int](($pageW-$drawW)/2)
                $y=[int](($pageH-$drawH)/2)
                $ev.Graphics.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $ev.Graphics.DrawImage($img,$x,$y,$drawW,$drawH)
                $ev.HasMorePages=$false
            })
            $pd.Print();$img.Dispose();$pd.Dispose()
        }
        '\.(docx?|xlsx?|pptx?)' {
            $psi=New-Object Diagnostics.ProcessStartInfo
            $psi.FileName=$FilePath;$psi.Verb="printto";$psi.Arguments="`"$PrinterName`""
            $psi.UseShellExecute=$true;$psi.WindowStyle=[Diagnostics.ProcessWindowStyle]::Hidden
            $p=[Diagnostics.Process]::Start($psi);$p.WaitForExit(30000)
        }
        default {
            $psi=New-Object Diagnostics.ProcessStartInfo
            $psi.FileName=$FilePath;$psi.Verb="print";$psi.UseShellExecute=$true
            $psi.WindowStyle=[Diagnostics.ProcessWindowStyle]::Hidden
            $p=[Diagnostics.Process]::Start($psi);Start-Sleep 5;if(-not $p.HasExited){$p.Kill()}
        }
    }

    # Post-impresion
    Start-Sleep -Seconds 2
    if($DeleteAfterPrint){
        Remove-Item -Path $FilePath -Force -ErrorAction SilentlyContinue
    } else {
        $doneDir=Join-Path (Split-Path $FilePath) "Impreso"
        if(-not(Test-Path $doneDir)){New-Item -ItemType Directory -Path $doneDir|Out-Null}
        $dest=Join-Path $doneDir (Split-Path $FilePath -Leaf)
        if(Test-Path $dest){Remove-Item $dest -Force}
        Move-Item -Path $FilePath -Destination $dest -Force
    }
}

# ── Watcher ──────────────────────────────────────────────────
function Start-Watcher { param($Folder,$Printer,[int]$Copies)
    if(-not(Test-Path $Folder)){New-Item -ItemType Directory -Path $Folder -Force|Out-Null}
    $script:activePrinter = $Printer
    $script:activeCopies  = $Copies
    $script:watchFolder   = $Folder
    # Capturar la config del cajon seleccionado en la UI en el momento de Iniciar
    $selBinKey = $lstBins.SelectedItem
    if($selBinKey -and $script:binConfigs.ContainsKey($selBinKey)){
        $script:activeBinCfg = $script:binConfigs[$selBinKey]
    } else {
        $script:activeBinCfg = @{PaperSize="A4";Landscape=$false;Duplex="Simplex";Color=$true;BinCode=-1}
    }
    $script:seenFiles     = [System.Collections.Generic.HashSet[string]]::new(
                                [System.StringComparer]::OrdinalIgnoreCase)

    $doneDir=Join-Path $Folder "Impreso"
    if(Test-Path $doneDir){
        Get-ChildItem $doneDir -File -EA SilentlyContinue |
            ForEach-Object{ [void]$script:seenFiles.Add((Join-Path $Folder $_.Name)) }
    }

    $script:watcherTimer = New-Object System.Windows.Threading.DispatcherTimer
    $script:watcherTimer.Interval = [TimeSpan]::FromSeconds(2)
    $script:watcherTimer.add_Tick({
        try {
            # Cosechar jobs terminados
            $done = $script:printJobs | Where-Object { $_.Job.State -in 'Completed','Failed','Stopped' }
            foreach ($item in $done) {
                $result = Receive-Job -Job $item.Job -ErrorAction SilentlyContinue
                $err    = $item.Job.ChildJobs[0].Error | Select-Object -First 1
                if ($err) {
                    Add-LogEntry -Event "ERROR" -File $item.FileName -Printer $item.Printer -Config $item.Config -Status $err.ToString()
                } else {
                    $statusMsg = if($item.Deleted){"Eliminado"} else {"Movido a /Impreso"}
                    Add-LogEntry -Event "Impreso OK" -File $item.FileName -Printer $item.Printer -Config $item.Config -Status $statusMsg
                    $lblStatusBar.Text = "Ultimo impreso: $($item.FileName)"
                }
                Remove-Job -Job $item.Job -Force
                [void]$script:printJobs.Remove($item)
            }

            # Detectar archivos nuevos
            if(-not(Test-Path $script:watchFolder)){return}
            $files = Get-ChildItem -Path $script:watchFolder -File -EA SilentlyContinue |
                     Where-Object { $_.FullName -notmatch "\\Impreso\\" }

            foreach ($f in $files) {
                if($script:seenFiles.Contains($f.FullName)){continue}
                [void]$script:seenFiles.Add($f.FullName)

                $currentDelete = ($chkDelete.IsChecked -eq $true)

                # Usar la config del cajon que estaba seleccionado al pulsar Iniciar
                $activeCfg = $script:activeBinCfg
                if(-not $activeCfg){
                    $activeCfg = @{PaperSize="A4";Landscape=$false;Duplex="Simplex";Color=$true;BinCode=-1}
                }

                $binCode  = $activeCfg.BinCode
                $cfgLabel = Get-ConfigLabel $activeCfg
                $printerLabel = "$($script:activePrinter)"

                # Convertir booleanos a int para que no se pierdan al cruzar Start-Job
                $argLandscape = [int]($activeCfg.Landscape -eq $true)
                $argColor     = [int]($activeCfg.Color     -ne $false)
                $argDelete    = [int]($currentDelete)
                $job = Start-Job -ScriptBlock $script:printScript -ArgumentList @(
                    $f.FullName,
                    $script:activePrinter,
                    $binCode,
                    $script:activeCopies,
                    $argDelete,
                    $activeCfg.PaperSize,
                    $argLandscape,
                    $activeCfg.Duplex,
                    $argColor
                )

                $script:printJobs.Add([PSCustomObject]@{
                    Job     = $job
                    FileName= $f.Name
                    Printer = $printerLabel
                    Config  = $cfgLabel
                    Deleted = $currentDelete
                })
                Add-LogEntry -Event "Recibido" -File $f.Name -Printer $printerLabel -Config $cfgLabel -Status "Enviando..."
            }
        } catch {
            Add-LogEntry -Event "WARN" -File "-" -Printer "-" -Config "-" -Status "Error en tick: $_"
        }
    })

    $script:watcherTimer.Start()
    Set-MonitorState $true
    Add-LogEntry -Event "Iniciado" -File $Folder -Printer $Printer -Config "-" -Status "Monitoreando"
    Set-StatusBar "Monitoreando: $Folder  ->  $Printer"
}

function Stop-Watcher {
    if($script:watcherTimer){ $script:watcherTimer.Stop(); $script:watcherTimer=$null }
    foreach($item in $script:printJobs){
        Stop-Job  $item.Job -EA SilentlyContinue
        Remove-Job $item.Job -Force -EA SilentlyContinue
    }
    $script:printJobs.Clear()
    Set-MonitorState $false
    Add-LogEntry -Event "Detenido" -File "-" -Printer "-" -Config "-" -Status "Monitor parado"
    Set-StatusBar "Monitor detenido."
}

# ── Eventos de ventana ───────────────────────────────────────
$window.add_Loaded({
    Load-Printers
    if($cboPrinter.SelectedItem){ Load-PaperBins $cboPrinter.SelectedItem }
})

$cboPrinter.add_SelectionChanged({
    if($cboPrinter.SelectedItem){ Load-PaperBins $cboPrinter.SelectedItem }
})

$lstBins.add_SelectionChanged({
    $sel = $lstBins.SelectedItem
    if(-not $sel){ return }
    $script:selectedBinKey = $sel
    $lblBinTitle.Text = "Configuracion: $sel"
    $lblBinSaved.Text = ""
    # Cargar config existente del cajon
    if($script:binConfigs.ContainsKey($sel)){
        Set-BinConfigUI $script:binConfigs[$sel]
    }
    $gridBinOptions.IsEnabled = $true
    $btnSaveBinConfig.IsEnabled = $true
})

$btnSaveBinConfig.add_Click({
    if(-not $script:selectedBinKey){ return }
    $cfg = Get-CurrentBinConfig
    # Preservar el BinCode del cajon
    if($script:binConfigs.ContainsKey($script:selectedBinKey)){
        $cfg.BinCode = $script:binConfigs[$script:selectedBinKey].BinCode
    }
    $script:binConfigs[$script:selectedBinKey] = $cfg
    $label = Get-ConfigLabel $cfg
    $lblBinSaved.Text = "Guardado: $label"
    if($script:savedMsgTimer){ $script:savedMsgTimer.Stop() }
    $script:savedMsgTimer = New-Object System.Windows.Threading.DispatcherTimer
    $script:savedMsgTimer.Interval = [TimeSpan]::FromSeconds(3)
    $script:savedMsgTimer.add_Tick({ $lblBinSaved.Text=""; $script:savedMsgTimer.Stop() })
    $script:savedMsgTimer.Start()
})

$btnBrowse.add_Click({
    $fbd=New-Object System.Windows.Forms.FolderBrowserDialog
    $fbd.Description="Selecciona la carpeta a monitorear"
    $fbd.SelectedPath=$txtHotFolder.Text
    if($fbd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK){
        $txtHotFolder.Text=$fbd.SelectedPath
    }
})

$btnStart.add_Click({
    $folder  = $txtHotFolder.Text.Trim()
    $printer = $cboPrinter.SelectedItem
    $copies  = [int]($txtCopies.Text -replace "[^0-9]","")
    if($copies -lt 1){$copies=1}
    if(-not $printer){
        [System.Windows.MessageBox]::Show("Selecciona una impresora.","Hot Folder Print",
            [System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Warning)|Out-Null
        return
    }
    if([string]::IsNullOrWhiteSpace($folder)){
        [System.Windows.MessageBox]::Show("Especifica una carpeta.","Hot Folder Print",
            [System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Warning)|Out-Null
        return
    }
    Start-Watcher -Folder $folder -Printer $printer -Copies $copies
})

$btnStop.add_Click({ Stop-Watcher })

$btnTestPrint.add_Click({
    $printer  = $cboPrinter.SelectedItem
    $selBin   = $lstBins.SelectedItem
    if(-not $printer){
        [System.Windows.MessageBox]::Show("Selecciona una impresora.","Hot Folder Print",
            [System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Warning)|Out-Null
        return
    }
    $cfg = if($selBin -and $script:binConfigs.ContainsKey($selBin)){
        $script:binConfigs[$selBin]
    } else {
        @{PaperSize="A4";Landscape=$false;Duplex="Simplex";Color=$true;BinCode=-1}
    }
    try{
        $pd=New-Object System.Drawing.Printing.PrintDocument
        $pd.PrinterSettings.PrinterName=$printer
        if($cfg.BinCode -gt 0){
            $src=$pd.PrinterSettings.PaperSources|Where-Object{$_.RawKind -eq $cfg.BinCode}|Select-Object -First 1
            if($src){$pd.DefaultPageSettings.PaperSource=$src}
        }
        $pd.DefaultPageSettings.Landscape = ($cfg.Landscape -eq $true)
        try { $pd.DefaultPageSettings.Color = ($cfg.Color -ne $false) } catch {}

        $cfgLabel = Get-ConfigLabel $cfg
        $pd.add_PrintPage({param($s,$ev)
            $f1=New-Object System.Drawing.Font("Segoe UI",18,[System.Drawing.FontStyle]::Bold)
            $f2=New-Object System.Drawing.Font("Segoe UI",11)
            $br=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
            $ev.Graphics.DrawString("Hot Folder Print Monitor",$f1,$br,60,80)
            $ev.Graphics.DrawString("Pagina de prueba",$f2,$br,60,130)
            $ev.Graphics.DrawString("Impresora : $printer",$f2,$br,60,160)
            $ev.Graphics.DrawString("Bandeja   : $(if($selBin){$selBin}else{'Auto'})",$f2,$br,60,185)
            $ev.Graphics.DrawString("Config    : $cfgLabel",$f2,$br,60,210)
            $ev.Graphics.DrawString("Fecha/Hora: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')",$f2,$br,60,235)
            $ev.HasMorePages=$false
            $f1.Dispose();$f2.Dispose();$br.Dispose()
        })
        $pd.Print();$pd.Dispose()
        Add-LogEntry -Event "Prueba" -File "test-page" -Printer $printer -Config $cfgLabel -Status "Enviada"
        Set-StatusBar "Pagina de prueba enviada a: $printer"
    } catch {
        [System.Windows.MessageBox]::Show("Error: $_","Hot Folder Print","OK","Error")|Out-Null
    }
})

$btnClearLog.add_Click({
    $lstLog.Items.Clear(); $script:fileCount=0; $lblCount.Text="0"
})

# ── System Tray ──────────────────────────────────────────────
$script:trayIcon = $null
$script:forceClose = $false

function Initialize-TrayIcon {
    $appIcon = Get-AppIcon

    $tray = New-Object System.Windows.Forms.NotifyIcon
    $tray.Icon    = $appIcon
    $tray.Text    = "Hot Folder Print Monitor"
    $tray.Visible = $true

    # Menu contextual
    $menu = New-Object System.Windows.Forms.ContextMenuStrip

    $itemShow = New-Object System.Windows.Forms.ToolStripMenuItem
    $itemShow.Text = "Mostrar / Ocultar"
    $itemShow.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $itemShow.add_Click({
        if ($window.IsVisible) {
            $window.Hide()
            $window.ShowInTaskbar = $false
        } else {
            $window.Show()
            $window.ShowInTaskbar = $true
            $window.Activate()
            if ($window.WindowState -eq [System.Windows.WindowState]::Minimized) {
                $window.WindowState = [System.Windows.WindowState]::Normal
            }
        }
    })

    $itemSep = New-Object System.Windows.Forms.ToolStripSeparator

    $itemExit = New-Object System.Windows.Forms.ToolStripMenuItem
    $itemExit.Text = "Cerrar aplicacion"
    $itemExit.add_Click({
        $script:forceClose = $true
        Stop-Watcher
        $script:trayIcon.Visible = $false
        $script:trayIcon.Dispose()
        $window.Close()
    })

    [void]$menu.Items.Add($itemShow)
    [void]$menu.Items.Add($itemSep)
    [void]$menu.Items.Add($itemExit)
    $tray.ContextMenuStrip = $menu

    # Doble clic en el icono: mostrar/ocultar ventana
    $tray.add_DoubleClick({
        if ($window.IsVisible) {
            $window.Hide()
            $window.ShowInTaskbar = $false
        } else {
            $window.Show()
            $window.ShowInTaskbar = $true
            $window.Activate()
            if ($window.WindowState -eq [System.Windows.WindowState]::Minimized) {
                $window.WindowState = [System.Windows.WindowState]::Normal
            }
        }
    })

    $script:trayIcon = $tray
}

# Interceptar el cierre de ventana: minimizar a bandeja en lugar de cerrar
$window.add_Closing({
    param($s, $e)
    if (-not $script:forceClose) {
        $e.Cancel = $true
        $window.Hide()
        $window.ShowInTaskbar = $false
        $script:trayIcon.ShowBalloonTip(
            2000,
            "Hot Folder Print",
            "La aplicacion sigue activa en la bandeja del sistema.",
            [System.Windows.Forms.ToolTipIcon]::Info
        )
    }
})

# Inicializar tray antes de mostrar la ventana
Initialize-TrayIcon

# Bucle de mensajes de Windows Forms necesario para el tray
$appCtx = New-Object System.Windows.Forms.ApplicationContext
[void]$window.ShowDialog()

# Limpiar al salir
if ($script:trayIcon) {
    $script:trayIcon.Visible = $false
    $script:trayIcon.Dispose()
}
