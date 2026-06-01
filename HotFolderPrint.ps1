#Requires -Version 5.1
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

# ── Extraer icono desde shell32 ───────────────────────────────
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public class NativeIcon {
    [DllImport("shell32.dll", CharSet=CharSet.Auto)]
    public static extern IntPtr ExtractIcon(IntPtr hInst, string lpszExeFileName, int nIconIndex);
}
'@ -ErrorAction SilentlyContinue

function Get-AppIcon {
    # Indice 46 = carpeta con lupa/accion (carpeta+impresora en muchos sistemas)
    # Indices a probar en orden: 46 (folder action), 259 (printer folder), 16 (folder), 17 (printer)
    foreach ($idx in @(46, 259, 16, 17)) {
        try {
            $hIcon = [NativeIcon]::ExtractIcon([IntPtr]::Zero, "$env:SystemRoot\System32\shell32.dll", $idx)
            if ($hIcon -ne [IntPtr]::Zero) {
                return [System.Drawing.Icon]::FromHandle($hIcon)
            }
        } catch {}
    }
    return [System.Drawing.SystemIcons]::Application
}

[xml]$XAML = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Hot Folder Print Monitor"
    Height="900" Width="1100"
    MinHeight="750" MinWidth="950"
    WindowStartupLocation="CenterScreen"
    Background="#0F0F13"
    ShowInTaskbar="True">

    <Window.Resources>
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
        <Style x:Key="DarkCombo" TargetType="ComboBox">
            <Setter Property="Background"      Value="White"/>
            <Setter Property="Foreground"      Value="#111111"/>
            <Setter Property="BorderBrush"     Value="#2D2D3D"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontSize"        Value="12"/>
            <Setter Property="Height"          Value="34"/>
            <Setter Property="Padding"         Value="8,4"/>
            <Setter Property="ItemContainerStyle">
                <Setter.Value>
                    <Style TargetType="ComboBoxItem">
                        <Setter Property="Foreground" Value="#111111"/>
                        <Setter Property="Background" Value="White"/>
                        <Setter Property="Padding"    Value="8,5"/>
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
        <Style x:Key="DarkRadio" TargetType="RadioButton">
            <Setter Property="Foreground" Value="#CBD5E1"/>
            <Setter Property="FontSize"   Value="12"/>
            <Setter Property="Cursor"     Value="Hand"/>
            <Setter Property="Margin"     Value="0,0,12,0"/>
        </Style>
        <Style x:Key="DarkCheck" TargetType="CheckBox">
            <Setter Property="Foreground" Value="#CBD5E1"/>
            <Setter Property="FontSize"   Value="12"/>
            <Setter Property="Cursor"     Value="Hand"/>
        </Style>
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
                <Trigger Property="IsSelected"  Value="True">
                    <Setter Property="Background" Value="#1E3A5F"/>
                </Trigger>
            </Style.Triggers>
        </Style>
        <Style x:Key="DarkGroup" TargetType="GroupBox">
            <Setter Property="Foreground"      Value="#94A3B8"/>
            <Setter Property="FontSize"        Value="11"/>
            <Setter Property="FontWeight"      Value="SemiBold"/>
            <Setter Property="BorderBrush"     Value="#2D2D3D"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding"         Value="8,6"/>
        </Style>
        <!-- Estilo para el TabControl oscuro -->
        <Style x:Key="DarkTab" TargetType="TabItem">
            <Setter Property="Foreground"  Value="#94A3B8"/>
            <Setter Property="Background"  Value="#1A1A22"/>
            <Setter Property="FontSize"    Value="12"/>
            <Setter Property="Padding"     Value="14,7"/>
            <Setter Property="Cursor"      Value="Hand"/>
        </Style>
    </Window.Resources>

    <Grid Margin="16">
        <Grid.RowDefinitions>
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
            <TextBlock Text="Monitorea hasta 3 carpetas e imprime automaticamente los archivos que lleguen"
                       Foreground="#64748B" FontSize="12" Margin="0,4,0,0"/>
        </StackPanel>

        <!-- CARPETAS (TabControl con 3 slots) -->
        <Border Grid.Row="1" Background="#1A1A22" CornerRadius="10"
                BorderBrush="#2D2D3D" BorderThickness="1" Padding="12" Margin="0,0,0,8">
            <StackPanel>
                <TextBlock Text="CARPETAS A MONITOREAR" Foreground="#64748B"
                           FontSize="10" FontWeight="SemiBold" Margin="0,0,0,10"/>
                <!-- Carpeta 1 -->
                <Grid Margin="0,0,0,6">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="60"/>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="8"/>
                        <ColumnDefinition Width="90"/>
                        <ColumnDefinition Width="8"/>
                        <ColumnDefinition Width="160"/>
                        <ColumnDefinition Width="8"/>
                        <ColumnDefinition Width="55"/>
                    </Grid.ColumnDefinitions>
                    <TextBlock Grid.Column="0" Text="Carpeta 1" Foreground="#64748B" FontSize="11" VerticalAlignment="Center"/>
                    <TextBox   x:Name="txtFolder1" Grid.Column="1" Style="{StaticResource DarkInput}" Text="C:\HotFolder1"/>
                    <Button    x:Name="btnBrowse1" Grid.Column="3" Content="Examinar..." Style="{StaticResource BtnNeutral}" Height="34" Padding="8,5"/>
                    <ComboBox  x:Name="cboPrinter1" Grid.Column="5" Style="{StaticResource DarkCombo}"/>
                    <TextBlock Grid.Column="6" Text="Copias" Foreground="#64748B" FontSize="11" VerticalAlignment="Center" HorizontalAlignment="Center"/>
                    <TextBox   x:Name="txtCopies1" Grid.Column="7" Style="{StaticResource DarkInput}" Text="1"/>
                </Grid>
                <!-- Carpeta 2 -->
                <Grid Margin="0,0,0,6">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="60"/>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="8"/>
                        <ColumnDefinition Width="90"/>
                        <ColumnDefinition Width="8"/>
                        <ColumnDefinition Width="160"/>
                        <ColumnDefinition Width="8"/>
                        <ColumnDefinition Width="55"/>
                    </Grid.ColumnDefinitions>
                    <TextBlock Grid.Column="0" Text="Carpeta 2" Foreground="#64748B" FontSize="11" VerticalAlignment="Center"/>
                    <TextBox   x:Name="txtFolder2" Grid.Column="1" Style="{StaticResource DarkInput}" Text="" IsEnabled="False"/>
                    <Button    x:Name="btnBrowse2" Grid.Column="3" Content="Examinar..." Style="{StaticResource BtnNeutral}" Height="34" Padding="8,5" IsEnabled="False"/>
                    <ComboBox  x:Name="cboPrinter2" Grid.Column="5" Style="{StaticResource DarkCombo}" IsEnabled="False"/>
                    <TextBlock Grid.Column="6" Text="Copias" Foreground="#64748B" FontSize="11" VerticalAlignment="Center" HorizontalAlignment="Center"/>
                    <TextBox   x:Name="txtCopies2" Grid.Column="7" Style="{StaticResource DarkInput}" Text="1" IsEnabled="False"/>
                </Grid>
                <!-- Carpeta 3 -->
                <Grid Margin="0,0,0,4">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="60"/>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="8"/>
                        <ColumnDefinition Width="90"/>
                        <ColumnDefinition Width="8"/>
                        <ColumnDefinition Width="160"/>
                        <ColumnDefinition Width="8"/>
                        <ColumnDefinition Width="55"/>
                    </Grid.ColumnDefinitions>
                    <TextBlock Grid.Column="0" Text="Carpeta 3" Foreground="#64748B" FontSize="11" VerticalAlignment="Center"/>
                    <TextBox   x:Name="txtFolder3" Grid.Column="1" Style="{StaticResource DarkInput}" Text="" IsEnabled="False"/>
                    <Button    x:Name="btnBrowse3" Grid.Column="3" Content="Examinar..." Style="{StaticResource BtnNeutral}" Height="34" Padding="8,5" IsEnabled="False"/>
                    <ComboBox  x:Name="cboPrinter3" Grid.Column="5" Style="{StaticResource DarkCombo}" IsEnabled="False"/>
                    <TextBlock Grid.Column="6" Text="Copias" Foreground="#64748B" FontSize="11" VerticalAlignment="Center" HorizontalAlignment="Center"/>
                    <TextBox   x:Name="txtCopies3" Grid.Column="7" Style="{StaticResource DarkInput}" Text="1" IsEnabled="False"/>
                </Grid>
                <!-- Checkboxes para activar carpetas 2 y 3 -->
                <StackPanel Orientation="Horizontal" Margin="60,4,0,0">
                    <CheckBox x:Name="chkEnable2" Content="Activar carpeta 2" Style="{StaticResource DarkCheck}" Margin="0,0,24,0"/>
                    <CheckBox x:Name="chkEnable3" Content="Activar carpeta 3" Style="{StaticResource DarkCheck}"/>
                </StackPanel>
            </StackPanel>
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
                    <Border Grid.Column="0" Background="#13131A" CornerRadius="8"
                            BorderBrush="#2D2D3D" BorderThickness="1">
                        <StackPanel>
                            <Border Background="#1E1E2E" CornerRadius="8,8,0,0" Padding="10,8">
                                <TextBlock Text="Cajones disponibles" Foreground="#94A3B8"
                                           FontSize="11" FontWeight="SemiBold"/>
                            </Border>
                            <ListBox x:Name="lstBins" Background="Transparent"
                                     BorderThickness="0" Foreground="#F1F5F9"
                                     FontSize="12" Padding="4" MinHeight="120">
                                <ListBox.ItemContainerStyle>
                                    <Style TargetType="ListBoxItem">
                                        <Setter Property="Foreground" Value="#CBD5E1"/>
                                        <Setter Property="Padding"    Value="8,6"/>
                                        <Setter Property="Cursor"     Value="Hand"/>
                                        <Style.Triggers>
                                            <Trigger Property="IsMouseOver" Value="True">
                                                <Setter Property="Background" Value="#22222E"/>
                                            </Trigger>
                                            <Trigger Property="IsSelected" Value="True">
                                                <Setter Property="Background" Value="#1E3A5F"/>
                                                <Setter Property="Foreground" Value="White"/>
                                            </Trigger>
                                        </Style.Triggers>
                                    </Style>
                                </ListBox.ItemContainerStyle>
                            </ListBox>
                        </StackPanel>
                    </Border>
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
                                <GroupBox Grid.Column="0" Header="Tamano de papel" Style="{StaticResource DarkGroup}">
                                    <StackPanel Margin="0,6,0,0">
                                        <RadioButton x:Name="rdoA4"     Content="A4"     Style="{StaticResource DarkRadio}" GroupName="PaperSize" IsChecked="True" Margin="0,0,0,4"/>
                                        <RadioButton x:Name="rdoA3"     Content="A3"     Style="{StaticResource DarkRadio}" GroupName="PaperSize" Margin="0,0,0,4"/>
                                        <RadioButton x:Name="rdoA5"     Content="A5"     Style="{StaticResource DarkRadio}" GroupName="PaperSize" Margin="0,0,0,4"/>
                                        <RadioButton x:Name="rdoLetter" Content="Letter" Style="{StaticResource DarkRadio}" GroupName="PaperSize"/>
                                    </StackPanel>
                                </GroupBox>
                                <GroupBox Grid.Column="2" Header="Orientacion" Style="{StaticResource DarkGroup}">
                                    <StackPanel Margin="0,6,0,0">
                                        <RadioButton x:Name="rdoPortrait"  Content="Vertical"   Style="{StaticResource DarkRadio}" GroupName="Orient" IsChecked="True" Margin="0,0,0,4"/>
                                        <RadioButton x:Name="rdoLandscape" Content="Horizontal" Style="{StaticResource DarkRadio}" GroupName="Orient"/>
                                    </StackPanel>
                                </GroupBox>
                                <GroupBox Grid.Column="4" Header="Impresion" Style="{StaticResource DarkGroup}">
                                    <StackPanel Margin="0,6,0,0">
                                        <RadioButton x:Name="rdoSimplex"      Content="Una cara"              Style="{StaticResource DarkRadio}" GroupName="Duplex" IsChecked="True" Margin="0,0,0,4"/>
                                        <RadioButton x:Name="rdoDuplex"       Content="Doble cara"            Style="{StaticResource DarkRadio}" GroupName="Duplex" Margin="0,0,0,4"/>
                                        <RadioButton x:Name="rdoDuplexTumble" Content="Doble cara (horiz.)"   Style="{StaticResource DarkRadio}" GroupName="Duplex"/>
                                    </StackPanel>
                                </GroupBox>
                                <GroupBox Grid.Column="6" Header="Color" Style="{StaticResource DarkGroup}">
                                    <StackPanel Margin="0,6,0,0">
                                        <RadioButton x:Name="rdoColor" Content="Color" Style="{StaticResource DarkRadio}" GroupName="ColorMode" IsChecked="True" Margin="0,0,0,4"/>
                                        <RadioButton x:Name="rdoBW"    Content="B/N"   Style="{StaticResource DarkRadio}" GroupName="ColorMode"/>
                                    </StackPanel>
                                </GroupBox>
                            </Grid>
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

        <!-- LOG -->
        <Border Grid.Row="3" Background="#1A1A22" CornerRadius="10"
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
                            <GridViewColumn Header="Hora"       Width="75"  DisplayMemberBinding="{Binding Time}"/>
                            <GridViewColumn Header="Evento"     Width="90"  DisplayMemberBinding="{Binding Event}"/>
                            <GridViewColumn Header="Archivo"    Width="200" DisplayMemberBinding="{Binding File}"/>
                            <GridViewColumn Header="Carpeta"    Width="120" DisplayMemberBinding="{Binding Folder}"/>
                            <GridViewColumn Header="Impresora"  Width="160" DisplayMemberBinding="{Binding Printer}"/>
                            <GridViewColumn Header="Config"     Width="180" DisplayMemberBinding="{Binding Config}"/>
                            <GridViewColumn Header="Estado"     Width="120" DisplayMemberBinding="{Binding Status}"/>
                        </GridView>
                    </ListView.View>
                </ListView>
            </Grid>
        </Border>

        <!-- BARRA DE CONTROLES -->
        <Border Grid.Row="4" Background="#13131A" CornerRadius="8"
                Padding="12,8" BorderBrush="#2D2D3D" BorderThickness="1">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="Auto"/>
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
                <Button x:Name="btnStop"  Grid.Column="1" Content="Detener"
                        Style="{StaticResource BtnDanger}" MinWidth="110" IsEnabled="False" Margin="0,0,8,0"/>
                <Button x:Name="btnTestPrint" Grid.Column="2" Content="Pagina de prueba"
                        Style="{StaticResource BtnNeutral}" MinWidth="140" Margin="0,0,8,0"/>
                <!-- Bug 1: IsChecked=True por defecto (eliminar al imprimir es el comportamiento por defecto) -->
                <CheckBox x:Name="chkDeleteAfterPrint" Grid.Column="3"
                          Content="Eliminar al imprimir" IsChecked="True"
                          Foreground="#94A3B8" VerticalAlignment="Center" Margin="4,0,0,0"
                          ToolTip="Marcado: elimina el archivo tras imprimir. Desmarcado: mueve a la carpeta /Impreso."/>
                <StackPanel Grid.Column="5" Orientation="Horizontal" VerticalAlignment="Center" Margin="0,0,12,0">
                    <Ellipse x:Name="statusDot" Width="10" Height="10" Fill="#374151"
                             VerticalAlignment="Center" Margin="0,0,6,0"/>
                    <TextBlock x:Name="lblStatus" Text="Detenido" Foreground="#64748B"
                               FontSize="12" VerticalAlignment="Center"/>
                </StackPanel>
                <Button x:Name="btnClearLog" Grid.Column="6" Content="Limpiar log"
                        Style="{StaticResource BtnNeutral}" MinWidth="100" Margin="0,0,8,0"/>
                <TextBlock Grid.Column="7" Text="Jonatan T35 v2.2"
                           Foreground="#374151" FontSize="10" VerticalAlignment="Center"/>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

# ── Cargar ventana ───────────────────────────────────────────
$reader = [System.Xml.XmlNodeReader]::new($XAML)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Controles carpeta 1
$txtFolder1   = $window.FindName("txtFolder1")
$btnBrowse1   = $window.FindName("btnBrowse1")
$cboPrinter1  = $window.FindName("cboPrinter1")
$txtCopies1   = $window.FindName("txtCopies1")
# Controles carpeta 2
$txtFolder2   = $window.FindName("txtFolder2")
$btnBrowse2   = $window.FindName("btnBrowse2")
$cboPrinter2  = $window.FindName("cboPrinter2")
$txtCopies2   = $window.FindName("txtCopies2")
$chkEnable2   = $window.FindName("chkEnable2")
# Controles carpeta 3
$txtFolder3   = $window.FindName("txtFolder3")
$btnBrowse3   = $window.FindName("btnBrowse3")
$cboPrinter3  = $window.FindName("cboPrinter3")
$txtCopies3   = $window.FindName("txtCopies3")
$chkEnable3   = $window.FindName("chkEnable3")
# Controles globales
$btnStart     = $window.FindName("btnStart")
$btnStop      = $window.FindName("btnStop")
$btnTestPrint = $window.FindName("btnTestPrint")
$btnClearLog  = $window.FindName("btnClearLog")
$chkDelete    = $window.FindName("chkDeleteAfterPrint")
$lstLog       = $window.FindName("lstLog")
$lblStatus    = $window.FindName("lblStatus")
$statusDot    = $window.FindName("statusDot")
$lblCount     = $window.FindName("lblCount")
# Cajones
$lstBins           = $window.FindName("lstBins")
$gridBinOptions    = $window.FindName("gridBinOptions")
$lblBinTitle       = $window.FindName("lblBinTitle")
$btnSaveBinConfig  = $window.FindName("btnSaveBinConfig")
$lblBinSaved       = $window.FindName("lblBinSaved")
# Radios
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
# Lista de watchers activos: cada uno es un hashtable con Timer, Folder, Printer, etc.
$script:activeWatchers   = [System.Collections.Generic.List[object]]::new()
$script:printJobs        = [System.Collections.Generic.List[object]]::new()
$script:fileCount        = 0
$script:savedMsgTimer    = $null
$script:binConfigs       = @{}
$script:binItems         = [System.Collections.Generic.List[object]]::new()
$script:selectedBinKey   = $null
$script:activeBinCfg     = $null
# Impresora de referencia para cargar cajones (la carpeta 1)
$script:refPrinterForBins = ""

# ── Helpers UI ───────────────────────────────────────────────
function Add-LogEntry {
    param($Event, $File, $Folder, $Printer, $Config, $Status)
    $entry = [PSCustomObject]@{
        Time    = (Get-Date -Format "HH:mm:ss")
        Event   = $Event
        File    = $File
        Folder  = $Folder
        Printer = $Printer
        Config  = $Config
        Status  = $Status
    }
    $lstLog.Items.Add($entry)
    $lstLog.ScrollIntoView($entry)
    $script:fileCount++
    $lblCount.Text = $script:fileCount.ToString()
}

function Set-MonitorState { param([bool]$running)
    if ($running) {
        $statusDot.Fill       = [System.Windows.Media.Brushes]::LimeGreen
        $lblStatus.Text       = "Monitoreando"
        $lblStatus.Foreground = [System.Windows.Media.Brushes]::LimeGreen
        $btnStart.IsEnabled   = $false
        $btnStop.IsEnabled    = $true
        # Bloquear solo la config de carpetas/impresoras, NO los cajones
        $txtFolder1.IsEnabled  = $false; $btnBrowse1.IsEnabled  = $false
        $cboPrinter1.IsEnabled = $false; $txtCopies1.IsEnabled  = $false
        $txtFolder2.IsEnabled  = $false; $btnBrowse2.IsEnabled  = $false
        $cboPrinter2.IsEnabled = $false; $txtCopies2.IsEnabled  = $false
        $txtFolder3.IsEnabled  = $false; $btnBrowse3.IsEnabled  = $false
        $cboPrinter3.IsEnabled = $false; $txtCopies3.IsEnabled  = $false
        $chkEnable2.IsEnabled  = $false; $chkEnable3.IsEnabled  = $false
    } else {
        $statusDot.Fill       = [System.Windows.Media.Brushes]::DimGray
        $lblStatus.Text       = "Detenido"
        $lblStatus.Foreground = [System.Windows.Media.Brushes]::Gray
        $btnStart.IsEnabled   = $true
        $btnStop.IsEnabled    = $false
        # Restaurar carpeta 1 siempre
        $txtFolder1.IsEnabled  = $true; $btnBrowse1.IsEnabled  = $true
        $cboPrinter1.IsEnabled = $true; $txtCopies1.IsEnabled  = $true
        # Carpetas 2 y 3 segun checkbox
        $en2 = ($chkEnable2.IsChecked -eq $true)
        $txtFolder2.IsEnabled  = $en2; $btnBrowse2.IsEnabled  = $en2
        $cboPrinter2.IsEnabled = $en2; $txtCopies2.IsEnabled  = $en2
        $chkEnable2.IsEnabled  = $true
        $en3 = ($chkEnable3.IsChecked -eq $true)
        $txtFolder3.IsEnabled  = $en3; $btnBrowse3.IsEnabled  = $en3
        $cboPrinter3.IsEnabled = $en3; $txtCopies3.IsEnabled  = $en3
        $chkEnable3.IsEnabled  = $true
        # Bug 2 fix: al detener, los cajones quedan accesibles si habia uno seleccionado
        if ($script:selectedBinKey) {
            $gridBinOptions.IsEnabled   = $true
            $btnSaveBinConfig.IsEnabled = $true
        }
    }
}

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

function Get-ConfigLabel { param($cfg)
    $ori = if($cfg.Landscape){"Horiz"}else{"Vert"}
    $dup = switch($cfg.Duplex){"Duplex"{"2C"};"DuplexTumble"{"2C-H"};default{"1C"}}
    $col = if($cfg.Color){"Color"}else{"B/N"}
    return "$($cfg.PaperSize) $ori $dup $col"
}

# ── Cargar impresoras en todos los ComboBox ──────────────────
function Load-Printers {
    $combos = @($cboPrinter1, $cboPrinter2, $cboPrinter3)
    try { $printers = Get-Printer -EA Stop | Select-Object -ExpandProperty Name }
    catch { $printers = Get-WmiObject -Query "SELECT Name FROM Win32_Printer" | Select-Object -ExpandProperty Name }
    $def = (Get-WmiObject -Query "SELECT Name FROM Win32_Printer WHERE Default=True" | Select-Object -First 1).Name
    foreach ($cbo in $combos) {
        $cbo.Items.Clear()
        foreach ($p in $printers) { [void]$cbo.Items.Add($p) }
        if ($def -and $cbo.Items.Contains($def)) { $cbo.SelectedItem = $def }
        elseif ($cbo.Items.Count -gt 0) { $cbo.SelectedIndex = 0 }
    }
}

# ── Cargar cajones (basado en impresora de carpeta 1) ────────
function Load-PaperBins { param($PrinterName)
    $script:refPrinterForBins = $PrinterName
    $lstBins.Items.Clear()
    $script:binItems.Clear()
    $script:binConfigs    = @{}
    $script:selectedBinKey = $null
    $gridBinOptions.IsEnabled    = $false
    $btnSaveBinConfig.IsEnabled  = $false
    $lblBinTitle.Text = "Selecciona un cajon para configurarlo"
    $lblBinSaved.Text = ""
    $added = $false
    try {
        $pd = New-Object System.Drawing.Printing.PrintDocument
        $pd.PrinterSettings.PrinterName = $PrinterName
        foreach ($src in $pd.PrinterSettings.PaperSources) {
            $script:binItems.Add([PSCustomObject]@{ Label=$src.SourceName; Code=[int]$src.RawKind })
            [void]$lstBins.Items.Add($src.SourceName)
            $script:binConfigs[$src.SourceName] = @{
                PaperSize="A4"; Landscape=$false; Duplex="Simplex"; Color=$true; BinCode=[int]$src.RawKind
            }
            $added = $true
        }
        $pd.Dispose()
    } catch {}
    if (-not $added) {
        foreach ($b in @(
            [PSCustomObject]@{Label="Seleccion automatica";Code=7},
            [PSCustomObject]@{Label="Bandeja multiuso";Code=4},
            [PSCustomObject]@{Label="Casete 1";Code=1},
            [PSCustomObject]@{Label="Casete 2";Code=3},
            [PSCustomObject]@{Label="Casete 3";Code=2}
        )) {
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
    [bool]$DeleteAfterPrint = [int]$DeleteAfterPrint
    [bool]$Landscape        = [int]$Landscape
    [bool]$ColorMode        = [int]$ColorMode

    function Apply-PrintSettings {
        param($pd,[int]$BinCode,[string]$PaperSize,[bool]$Landscape,[string]$Duplex,[bool]$ColorMode)
        if ($BinCode -gt 0) {
            $src = $pd.PrinterSettings.PaperSources | Where-Object{$_.RawKind -eq $BinCode} | Select-Object -First 1
            if ($src) { $pd.DefaultPageSettings.PaperSource = $src }
        }
        $paperMap = @{A4=9;A3=8;A5=11;Letter=1}
        $tk = $paperMap[$PaperSize]
        if ($tk) {
            $ps = $pd.PrinterSettings.PaperSizes | Where-Object{$_.RawKind -eq $tk} | Select-Object -First 1
            if (-not $ps) { $ps = $pd.PrinterSettings.PaperSizes | Where-Object{$_.PaperName -like "*$PaperSize*"} | Select-Object -First 1 }
            if ($ps) { $pd.DefaultPageSettings.PaperSize = $ps }
        }
        $pd.DefaultPageSettings.Landscape = $Landscape
        try {
            switch($Duplex){
                "Duplex"       {$pd.PrinterSettings.Duplex=[Drawing.Printing.Duplex]::Default}
                "DuplexTumble" {$pd.PrinterSettings.Duplex=[Drawing.Printing.Duplex]::Horizontal}
                default        {$pd.PrinterSettings.Duplex=[Drawing.Printing.Duplex]::Simplex}
            }
        } catch {}
        try { $pd.DefaultPageSettings.Color = $ColorMode } catch {}
    }

    $ok=$false
    for($i=0;$i -lt 60;$i++){
        try{$fs=[IO.File]::Open($FilePath,'Open','ReadWrite','None');$fs.Close();$fs.Dispose();$ok=$true;break}
        catch{Start-Sleep -Milliseconds 500}
    }
    if(-not $ok){throw "Archivo bloqueado o inaccesible"}

    $ext=[IO.Path]::GetExtension($FilePath).ToLower()
    switch -Regex ($ext) {
        '\.pdf' {
            $s=@("$env:ProgramFiles\SumatraPDF\SumatraPDF.exe",
                 "${env:ProgramFiles(x86)}\SumatraPDF\SumatraPDF.exe",
                 "$env:LOCALAPPDATA\SumatraPDF\SumatraPDF.exe") |
               Where-Object{Test-Path $_} | Select-Object -First 1
            if($s){
                $ps2="copies=$Copies"
                if($BinCode -gt 0){$ps2+=",bin=$BinCode"}
                if($Duplex -eq "Duplex"){$ps2+=",duplex"}
                if($Duplex -eq "DuplexTumble"){$ps2+=",duplextumble"}
                if($Landscape){$ps2+=",landscape"}
                if(-not $ColorMode){$ps2+=",monochrome"}
                $p=Start-Process $s -ArgumentList "-print-to `"$PrinterName`" -print-settings `"$ps2`" -silent `"$FilePath`"" -Wait -WindowStyle Hidden -PassThru
            } else {
                $psi=New-Object Diagnostics.ProcessStartInfo
                $psi.FileName=$FilePath;$psi.Verb="printto";$psi.Arguments="`"$PrinterName`""
                $psi.UseShellExecute=$true;$psi.WindowStyle=[Diagnostics.ProcessWindowStyle]::Hidden
                $p=[Diagnostics.Process]::Start($psi);if($p){$p.WaitForExit(30000);if(-not $p.HasExited){$p.Kill()}}
            }
        }
        '\.(txt|log|csv)' {
            $pd=New-Object Drawing.Printing.PrintDocument
            $pd.PrinterSettings.PrinterName=$PrinterName;$pd.PrinterSettings.Copies=[int16]$Copies
            Apply-PrintSettings -pd $pd -BinCode $BinCode -PaperSize $PaperSize -Landscape $Landscape -Duplex $Duplex -ColorMode $ColorMode
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
            $pd.PrinterSettings.PrinterName=$PrinterName;$pd.PrinterSettings.Copies=[int16]$Copies
            Apply-PrintSettings -pd $pd -BinCode $BinCode -PaperSize $PaperSize -Landscape $Landscape -Duplex $Duplex -ColorMode $ColorMode
            $img=[Drawing.Image]::FromFile($FilePath)
            $pd.add_PrintPage({param($s,$ev)
                $b=$ev.Graphics.VisibleClipBounds
                $imgW=$img.Width;$imgH=$img.Height;$pageW=$b.Width;$pageH=$b.Height
                if(($imgW -gt $imgH -and $pageW -lt $pageH) -or ($imgW -lt $imgH -and $pageW -gt $pageH)){
                    $img.RotateFlip([Drawing.RotateFlipType]::Rotate90FlipNone);$imgW=$img.Width;$imgH=$img.Height
                }
                $r=[Math]::Min([double]$pageW/[double]$imgW,[double]$pageH/[double]$imgH)
                $drawW=[int]($imgW*$r);$drawH=[int]($imgH*$r)
                $ev.Graphics.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $ev.Graphics.DrawImage($img,[int](($pageW-$drawW)/2),[int](($pageH-$drawH)/2),$drawW,$drawH)
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
    Start-Sleep -Seconds 2
    if($DeleteAfterPrint){
        Remove-Item -Path $FilePath -Force -EA SilentlyContinue
    } else {
        $doneDir=Join-Path (Split-Path $FilePath) "Impreso"
        if(-not(Test-Path $doneDir)){New-Item -ItemType Directory -Path $doneDir|Out-Null}
        $dest=Join-Path $doneDir (Split-Path $FilePath -Leaf)
        if(Test-Path $dest){Remove-Item $dest -Force}
        Move-Item -Path $FilePath -Destination $dest -Force
    }
}

# ── Iniciar watcher para una carpeta concreta ────────────────
function Start-SingleWatcher { param($Folder,$Printer,$Copies,$BinCfg,$SlotName)
    if(-not(Test-Path $Folder)){New-Item -ItemType Directory -Path $Folder -Force|Out-Null}

    $seenFiles = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $doneDir = Join-Path $Folder "Impreso"
    if(Test-Path $doneDir){
        Get-ChildItem $doneDir -File -EA SilentlyContinue |
            ForEach-Object{ [void]$seenFiles.Add((Join-Path $Folder $_.Name)) }
    }

    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromSeconds(2)

    $watcher = @{
        Timer     = $timer
        Folder    = $Folder
        Printer   = $Printer
        Copies    = $Copies
        BinCfg    = $BinCfg
        SlotName  = $SlotName
        SeenFiles = $seenFiles
    }

    $timer.add_Tick({
        try {
            # Cosechar jobs terminados de este watcher
            $done = $script:printJobs | Where-Object { $_.Slot -eq $watcher.SlotName -and $_.Job.State -in 'Completed','Failed','Stopped' }
            foreach ($item in @($done)) {
                $err = $item.Job.ChildJobs[0].Error | Select-Object -First 1
                if ($err) {
                    Add-LogEntry -Event "ERROR" -File $item.FileName -Folder $watcher.SlotName -Printer $item.Printer -Config $item.Config -Status $err.ToString()
                } else {
                    $msg = if($item.Deleted){"Eliminado"}else{"-> /Impreso"}
                    Add-LogEntry -Event "OK" -File $item.FileName -Folder $watcher.SlotName -Printer $item.Printer -Config $item.Config -Status $msg
                }
                Remove-Job -Job $item.Job -Force -EA SilentlyContinue
                [void]$script:printJobs.Remove($item)
            }

            if(-not(Test-Path $watcher.Folder)){return}
            $files = Get-ChildItem -Path $watcher.Folder -File -EA SilentlyContinue |
                     Where-Object { $_.FullName -notmatch "\\Impreso\\" }

            foreach ($f in $files) {
                if($watcher.SeenFiles.Contains($f.FullName)){continue}
                [void]$watcher.SeenFiles.Add($f.FullName)

                $currentDelete = ($chkDelete.IsChecked -eq $true)
                $cfg = $watcher.BinCfg
                if(-not $cfg){ $cfg = @{PaperSize="A4";Landscape=$false;Duplex="Simplex";Color=$true;BinCode=-1} }

                $argLandscape = [int]($cfg.Landscape -eq $true)
                $argColor     = [int]($cfg.Color -ne $false)
                $argDelete    = [int]$currentDelete

                $job = Start-Job -ScriptBlock $script:printScript -ArgumentList @(
                    $f.FullName, $watcher.Printer, $cfg.BinCode, $watcher.Copies,
                    $argDelete, $cfg.PaperSize, $argLandscape, $cfg.Duplex, $argColor
                )
                $cfgLabel = Get-ConfigLabel $cfg
                $script:printJobs.Add([PSCustomObject]@{
                    Job      = $job
                    FileName = $f.Name
                    Printer  = $watcher.Printer
                    Config   = $cfgLabel
                    Deleted  = $currentDelete
                    Slot     = $watcher.SlotName
                })
                Add-LogEntry -Event "Recibido" -File $f.Name -Folder $watcher.SlotName -Printer $watcher.Printer -Config $cfgLabel -Status "Enviando..."
            }
        } catch {
            Add-LogEntry -Event "WARN" -File "-" -Folder $watcher.SlotName -Printer "-" -Config "-" -Status "Error: $_"
        }
    })

    $timer.Start()
    return $watcher
}

function Start-AllWatchers {
    $script:activeBinCfg = if($script:selectedBinKey -and $script:binConfigs.ContainsKey($script:selectedBinKey)){
        $script:binConfigs[$script:selectedBinKey]
    } else {
        @{PaperSize="A4";Landscape=$false;Duplex="Simplex";Color=$true;BinCode=-1}
    }

    $slots = @(
        @{ Enabled=$true;          Folder=$txtFolder1.Text.Trim(); Printer=$cboPrinter1.SelectedItem; Copies=[int]($txtCopies1.Text -replace "[^0-9]",""); Name="Carpeta1" },
        @{ Enabled=($chkEnable2.IsChecked -eq $true); Folder=$txtFolder2.Text.Trim(); Printer=$cboPrinter2.SelectedItem; Copies=[int]($txtCopies2.Text -replace "[^0-9]",""); Name="Carpeta2" },
        @{ Enabled=($chkEnable3.IsChecked -eq $true); Folder=$txtFolder3.Text.Trim(); Printer=$cboPrinter3.SelectedItem; Copies=[int]($txtCopies3.Text -replace "[^0-9]",""); Name="Carpeta3" }
    )

    $anyOk = $false
    foreach ($slot in $slots) {
        if(-not $slot.Enabled){ continue }
        if([string]::IsNullOrWhiteSpace($slot.Folder)){
            [System.Windows.MessageBox]::Show("La $($slot.Name) esta activa pero sin carpeta especificada.",
                "Hot Folder Print",[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Warning)|Out-Null
            continue
        }
        if(-not $slot.Printer){
            [System.Windows.MessageBox]::Show("La $($slot.Name) no tiene impresora seleccionada.",
                "Hot Folder Print",[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Warning)|Out-Null
            continue
        }
        $copies = $slot.Copies; if($copies -lt 1){$copies=1}
        $w = Start-SingleWatcher -Folder $slot.Folder -Printer $slot.Printer -Copies $copies `
                                 -BinCfg $script:activeBinCfg -SlotName $slot.Name
        $script:activeWatchers.Add($w)
        Add-LogEntry -Event "Iniciado" -File $slot.Folder -Folder $slot.Name -Printer $slot.Printer -Config "-" -Status "Monitoreando"
        $anyOk = $true
    }

    if($anyOk){
        Set-MonitorState $true
    }
}

function Stop-AllWatchers {
    foreach ($w in $script:activeWatchers) {
        try { $w.Timer.Stop() } catch {}
    }
    $script:activeWatchers.Clear()
    foreach ($item in $script:printJobs) {
        Stop-Job  $item.Job -EA SilentlyContinue
        Remove-Job $item.Job -Force -EA SilentlyContinue
    }
    $script:printJobs.Clear()
    Set-MonitorState $false
    Add-LogEntry -Event "Detenido" -File "-" -Folder "-" -Printer "-" -Config "-" -Status "Monitor parado"
}

# ── Eventos ───────────────────────────────────────────────────
$window.add_Loaded({
    Load-Printers
    if($cboPrinter1.SelectedItem){ Load-PaperBins $cboPrinter1.SelectedItem }
})

$cboPrinter1.add_SelectionChanged({
    if($cboPrinter1.SelectedItem){ Load-PaperBins $cboPrinter1.SelectedItem }
})

# Activar/desactivar carpetas 2 y 3
$chkEnable2.add_Checked({
    $txtFolder2.IsEnabled=$true;$btnBrowse2.IsEnabled=$true;$cboPrinter2.IsEnabled=$true;$txtCopies2.IsEnabled=$true
})
$chkEnable2.add_Unchecked({
    $txtFolder2.IsEnabled=$false;$btnBrowse2.IsEnabled=$false;$cboPrinter2.IsEnabled=$false;$txtCopies2.IsEnabled=$false
})
$chkEnable3.add_Checked({
    $txtFolder3.IsEnabled=$true;$btnBrowse3.IsEnabled=$true;$cboPrinter3.IsEnabled=$true;$txtCopies3.IsEnabled=$true
})
$chkEnable3.add_Unchecked({
    $txtFolder3.IsEnabled=$false;$btnBrowse3.IsEnabled=$false;$cboPrinter3.IsEnabled=$false;$txtCopies3.IsEnabled=$false
})

# Botones Examinar
foreach ($pair in @(
    @{Btn=$btnBrowse1;Txt=$txtFolder1},
    @{Btn=$btnBrowse2;Txt=$txtFolder2},
    @{Btn=$btnBrowse3;Txt=$txtFolder3}
)) {
    $btn=$pair.Btn; $txt=$pair.Txt
    $btn.add_Click({
        $fbd=New-Object System.Windows.Forms.FolderBrowserDialog
        $fbd.Description="Selecciona la carpeta a monitorear"
        $fbd.SelectedPath=$txt.Text
        if($fbd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK){
            $txt.Text=$fbd.SelectedPath
        }
    }.GetNewClosure())
}

$lstBins.add_SelectionChanged({
    $sel=$lstBins.SelectedItem
    if(-not $sel){return}
    $script:selectedBinKey=$sel
    $lblBinTitle.Text="Configuracion: $sel"
    $lblBinSaved.Text=""
    if($script:binConfigs.ContainsKey($sel)){ Set-BinConfigUI $script:binConfigs[$sel] }
    $gridBinOptions.IsEnabled=$true
    $btnSaveBinConfig.IsEnabled=$true
})

$btnSaveBinConfig.add_Click({
    if(-not $script:selectedBinKey){return}
    $cfg = Get-CurrentBinConfig
    if($script:binConfigs.ContainsKey($script:selectedBinKey)){
        $cfg.BinCode=$script:binConfigs[$script:selectedBinKey].BinCode
    }
    $script:binConfigs[$script:selectedBinKey]=$cfg
    $lblBinSaved.Text="Guardado: $(Get-ConfigLabel $cfg)"
    if($script:savedMsgTimer){$script:savedMsgTimer.Stop()}
    $script:savedMsgTimer=New-Object System.Windows.Threading.DispatcherTimer
    $script:savedMsgTimer.Interval=[TimeSpan]::FromSeconds(3)
    $script:savedMsgTimer.add_Tick({$lblBinSaved.Text="";$script:savedMsgTimer.Stop()})
    $script:savedMsgTimer.Start()
})

$btnStart.add_Click({ Start-AllWatchers })
$btnStop.add_Click({  Stop-AllWatchers  })

$btnTestPrint.add_Click({
    $printer=$cboPrinter1.SelectedItem
    $selBin=$lstBins.SelectedItem
    if(-not $printer){
        [System.Windows.MessageBox]::Show("Selecciona una impresora en Carpeta 1.","Hot Folder Print",
            [System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Warning)|Out-Null;return
    }
    $cfg=if($selBin -and $script:binConfigs.ContainsKey($selBin)){$script:binConfigs[$selBin]}
         else{@{PaperSize="A4";Landscape=$false;Duplex="Simplex";Color=$true;BinCode=-1}}
    try{
        $pd=New-Object System.Drawing.Printing.PrintDocument
        $pd.PrinterSettings.PrinterName=$printer
        if($cfg.BinCode -gt 0){
            $src=$pd.PrinterSettings.PaperSources|Where-Object{$_.RawKind -eq $cfg.BinCode}|Select-Object -First 1
            if($src){$pd.DefaultPageSettings.PaperSource=$src}
        }
        $pd.DefaultPageSettings.Landscape=($cfg.Landscape -eq $true)
        try{$pd.DefaultPageSettings.Color=($cfg.Color -ne $false)}catch{}
        $cfgLabel=Get-ConfigLabel $cfg
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
            $ev.HasMorePages=$false;$f1.Dispose();$f2.Dispose();$br.Dispose()
        })
        $pd.Print();$pd.Dispose()
        Add-LogEntry -Event "Prueba" -File "test-page" -Folder "-" -Printer $printer -Config $cfgLabel -Status "Enviada"
    }catch{
        [System.Windows.MessageBox]::Show("Error: $_","Hot Folder Print","OK","Error")|Out-Null
    }
})

$btnClearLog.add_Click({
    $lstLog.Items.Clear();$script:fileCount=0;$lblCount.Text="0"
})

# ── System Tray ──────────────────────────────────────────────
$script:trayIcon  = $null
$script:forceClose = $false

function Initialize-TrayIcon {
    $tray = New-Object System.Windows.Forms.NotifyIcon
    $tray.Icon    = Get-AppIcon
    $tray.Text    = "Hot Folder Print Monitor"
    $tray.Visible = $true

    $menu = New-Object System.Windows.Forms.ContextMenuStrip

    $itemShow = New-Object System.Windows.Forms.ToolStripMenuItem
    $itemShow.Text = "Mostrar / Ocultar"
    $itemShow.Font = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Bold)
    $itemShow.add_Click({
        if($window.IsVisible){$window.Hide();$window.ShowInTaskbar=$false}
        else{$window.Show();$window.ShowInTaskbar=$true;$window.Activate()
             if($window.WindowState -eq [System.Windows.WindowState]::Minimized){
                 $window.WindowState=[System.Windows.WindowState]::Normal}}
    })
    $itemSep  = New-Object System.Windows.Forms.ToolStripSeparator
    $itemExit = New-Object System.Windows.Forms.ToolStripMenuItem
    $itemExit.Text = "Cerrar aplicacion"
    $itemExit.add_Click({
        $script:forceClose=$true
        Stop-AllWatchers
        $script:trayIcon.Visible=$false;$script:trayIcon.Dispose();$window.Close()
    })
    [void]$menu.Items.Add($itemShow)
    [void]$menu.Items.Add($itemSep)
    [void]$menu.Items.Add($itemExit)
    $tray.ContextMenuStrip=$menu

    $tray.add_DoubleClick({
        if($window.IsVisible){$window.Hide();$window.ShowInTaskbar=$false}
        else{$window.Show();$window.ShowInTaskbar=$true;$window.Activate()
             if($window.WindowState -eq [System.Windows.WindowState]::Minimized){
                 $window.WindowState=[System.Windows.WindowState]::Normal}}
    })
    $script:trayIcon=$tray
}

$window.add_Closing({
    param($s,$e)
    if(-not $script:forceClose){
        $e.Cancel=$true;$window.Hide();$window.ShowInTaskbar=$false
        $script:trayIcon.ShowBalloonTip(2000,"Hot Folder Print",
            "La aplicacion sigue activa en la bandeja del sistema.",
            [System.Windows.Forms.ToolTipIcon]::Info)
    }
})

Initialize-TrayIcon
[void]$window.ShowDialog()
if($script:trayIcon){$script:trayIcon.Visible=$false;$script:trayIcon.Dispose()}
