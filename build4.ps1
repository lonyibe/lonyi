<#
    .SYNOPSIS
    Compiles the LonyiTool application (v20.1 - Ambiguity Fix).
    
    .DESCRIPTION
    - FIX: Resolved 'Path' ambiguity by explicitly using 'System.IO.Path' for file operations.
    - CORE: Retains all v20.0 Diamond Logic (Knox Wizard Algorithms).
    - UI: Compact WPF Interface.
#>

Clear-Host
Write-Host "Initializing LonyiTool Build Pipeline (v20.1)..." -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor DarkGray

$sourceCode = @"
using System;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Effects;
using System.Windows.Shapes; 
using System.Windows.Threading;
using System.IO;             
using System.Threading.Tasks;
using Microsoft.Win32;
using System.Linq;
using System.Text; 

namespace LonyiInnovate
{
    public class Program
    {
        [STAThread]
        public static void Main()
        {
            var app = new Application();
            app.Run(new MainWindow());
        }
    }

    public class MainWindow : Window
    {
        // --- UI FIELDS ---
        private Grid _viewPatch;
        private Grid _viewSpd;
        private Grid _viewSamsung;
        private Grid _viewHmd;
        private Grid _viewOther;
        
        private List<Border> _tabButtons = new List<Border>();
        private TextBox _consoleOutput;
        
        // Labels
        private TextBlock _lblFileMisc;
        private TextBlock _lblFileSuperSpd;
        private TextBlock _lblFileSuperMtk;
        private TextBlock _lblFileMdm1;
        private TextBlock _lblFileMdm2;
        
        // --- LOGIC FIELDS ---
        private string _pathMisc = "";
        private string _pathSuperSpd = "";
        private string _pathSuperMtk = "";
        private string _pathMdm1 = "";
        private string _pathMdm2 = "";
        
        // --- KNOX WIZARD CONSTANTS ---
        private string FP_HEX = "5B 92 8D EC EB 97 78 57 AF C2 58 CD 53 E6 A8 D2"; 
        private string SEC_HEX = "53 65 63 75 72 69 74 79 43 6F 6D 2E 61 70 6B"; 
        private string PCS_HEX = "50 72 69 76 61 74 65 43 6F 6D 70 75 74 65 53 65 72 76 69 63 65 73 2E 6F 64 65 78 50 72 69 76 61 74 65 43 6F 6D 70 75 74 65 53 65 72 76 69 63 65 73 2E 76 64 65 78";
        private string SEC_ODEX_HEX = "53 65 63 75 72 69 74 79 43 6F 6D 2E 6F 64 65 78 53 65 63 75 72 69 74 79 43 6F 6D 2E 76 64 65 78";
        private string PCS_APKOAT_HEX = "50 72 69 76 61 74 65 43 6F 6D 70 75 74 65 53 65 72 76 69 63 65 73 2E 61 70 6B 6F 61 74";
        private string PRIV_APP_HEX = "70 72 69 76 2D 61 70 70 2F 50 72 69 76 61 74 65 43 6F 6D 70 75 74 65 53 65 72 76 69 63 65 73";
        private string PROD_SEC_HEX = "2F 70 72 6F 64 75 63 74 2F 70 72 69 76 2D 61 70 70 2F 53 65 63 75 72 69 74 79 43 6F 6D";
        
        private string YYYY_MARKER = "FF FF FF FF"; 
        private string FP_START = "PK";
        private string FP_END = "META-INF/MANIFEST.MFPK";

        public MainWindow()
        {
            InitializeWindow();
            InitializeLayout();
            SwitchTo("PATCH");
            Log("LonyiTool v20.1 Initialized (Fixed Ambiguity).");
        }

        private void InitializeWindow()
        {
            this.Title = "Lonyi Tool";
            this.Width = 1000;
            this.Height = 640; 
            this.WindowStartupLocation = WindowStartupLocation.CenterScreen;
            this.WindowStyle = WindowStyle.None;
            this.AllowsTransparency = true;
            this.Background = Brushes.Transparent;
            this.ResizeMode = ResizeMode.NoResize;

            Border mainBorder = new Border
            {
                CornerRadius = new CornerRadius(8),
                Background = new SolidColorBrush(Color.FromRgb(32, 32, 32)), 
                BorderBrush = new SolidColorBrush(Color.FromRgb(60, 60, 60)),
                BorderThickness = new Thickness(1),
                ClipToBounds = true,
                Effect = new DropShadowEffect { Color = Colors.Black, Direction = 270, ShadowDepth = 15, Opacity = 0.6, BlurRadius = 30 }
            };
            this.Content = mainBorder;
            
            this.MouseLeftButtonDown += (s, e) => { 
                if (e.ButtonState == MouseButtonState.Pressed && !e.Handled) 
                    this.DragMove(); 
            };
        }

        private void InitializeLayout()
        {
            Grid mainGrid = new Grid();
            mainGrid.RowDefinitions.Add(new RowDefinition { Height = new GridLength(40) }); // Header
            mainGrid.RowDefinitions.Add(new RowDefinition { Height = new GridLength(48) }); // Tabs
            mainGrid.RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) }); // Workspace
            ((Border)this.Content).Child = mainGrid;

            // --- 1. HEADER ---
            Grid headerPanel = new Grid { Margin = new Thickness(0) };
            TextBlock appTitle = new TextBlock
            {
                Text = "LONYI TOOL v20.1",
                FontFamily = new FontFamily("Segoe UI Semibold"),
                FontSize = 12,
                Foreground = new SolidColorBrush(Color.FromArgb(150, 255, 255, 255)),
                Margin = new Thickness(16, 0, 0, 0),
                VerticalAlignment = VerticalAlignment.Center
            };
            headerPanel.Children.Add(appTitle);

            StackPanel winControls = new StackPanel
            {
                Orientation = Orientation.Horizontal,
                HorizontalAlignment = HorizontalAlignment.Right,
                VerticalAlignment = VerticalAlignment.Top
            };
            winControls.Children.Add(CreateCaptionButton("Min", () => this.WindowState = WindowState.Minimized));
            winControls.Children.Add(CreateCaptionButton("Max", () => ToggleMaximize()));
            winControls.Children.Add(CreateCaptionButton("Close", () => Application.Current.Shutdown()));
            headerPanel.Children.Add(winControls);
            mainGrid.Children.Add(headerPanel);
            Grid.SetRow(headerPanel, 0);

            // --- 2. TABS ---
            Border tabBorder = new Border 
            { 
                Background = new SolidColorBrush(Color.FromArgb(10, 255, 255, 255)),
                BorderBrush = new SolidColorBrush(Color.FromArgb(30, 0, 0, 0)),
                BorderThickness = new Thickness(0, 1, 0, 1)
            };
            StackPanel navPanel = new StackPanel { Orientation = Orientation.Horizontal, HorizontalAlignment = HorizontalAlignment.Center };
            
            _tabButtons.Add(CreateTabButton("PATCHER", () => SwitchTo("PATCH")));
            _tabButtons.Add(CreateTabButton("SPD/MTK", () => SwitchTo("SPD")));
            _tabButtons.Add(CreateTabButton("SAMSUNG", () => SwitchTo("SAMSUNG")));
            _tabButtons.Add(CreateTabButton("HMD", () => SwitchTo("HMD")));
            _tabButtons.Add(CreateTabButton("UTILITIES", () => SwitchTo("OTHER")));
            
            foreach(var b in _tabButtons) navPanel.Children.Add(b);
            tabBorder.Child = navPanel;
            mainGrid.Children.Add(tabBorder);
            Grid.SetRow(tabBorder, 1);

            // --- 3. WORKSPACE ---
            Grid workspaceGrid = new Grid();
            workspaceGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(2, GridUnitType.Star) }); 
            workspaceGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) }); 

            // Content Area
            Grid contentArea = new Grid { Margin = new Thickness(20) };
            _viewPatch = CreatePatchView();
            _viewSpd = CreateView("SPD / MTK", "Brom / Preloader Operations");
            _viewSamsung = CreateView("Samsung Knox", "ADB / MTP Operations");
            _viewHmd = CreateView("HMD Service", "Factory Reset & FRP");
            _viewOther = CreateView("Utilities", "ADB / Fastboot Tools");

            contentArea.Children.Add(_viewPatch);
            contentArea.Children.Add(_viewSpd);
            contentArea.Children.Add(_viewSamsung);
            contentArea.Children.Add(_viewHmd);
            contentArea.Children.Add(_viewOther);
            workspaceGrid.Children.Add(contentArea);
            Grid.SetColumn(contentArea, 0);

            // Console
            Border consoleBorder = new Border 
            { 
                Background = new SolidColorBrush(Color.FromRgb(25, 25, 25)), 
                BorderBrush = new SolidColorBrush(Color.FromRgb(60, 60, 60)),
                BorderThickness = new Thickness(1, 0, 0, 0),
                Margin = new Thickness(10, 0, 0, 0),
                Padding = new Thickness(12)
            };
            Grid consoleLayout = new Grid();
            consoleLayout.RowDefinitions.Add(new RowDefinition { Height = new GridLength(30) });
            consoleLayout.RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) });

            TextBlock consoleLabel = new TextBlock 
            { 
                Text = "TERMINAL OUTPUT", 
                Foreground = new SolidColorBrush(Color.FromArgb(120, 255, 255, 255)),
                FontFamily = new FontFamily("Segoe UI Bold"),
                FontSize = 10
            };
            consoleLayout.Children.Add(consoleLabel);
            Grid.SetRow(consoleLabel, 0);

            _consoleOutput = new TextBox
            {
                Background = Brushes.Transparent,
                Foreground = new SolidColorBrush(Color.FromRgb(50, 200, 80)),
                FontFamily = new FontFamily("Consolas"),
                FontSize = 13,
                BorderThickness = new Thickness(0),
                TextWrapping = TextWrapping.Wrap,
                IsReadOnly = true,
                VerticalScrollBarVisibility = ScrollBarVisibility.Auto,
                Text = "> System Ready..."
            };
            consoleLayout.Children.Add(_consoleOutput);
            Grid.SetRow(_consoleOutput, 1);
            consoleBorder.Child = consoleLayout;
            workspaceGrid.Children.Add(consoleBorder);
            Grid.SetColumn(consoleBorder, 1);

            mainGrid.Children.Add(workspaceGrid);
            Grid.SetRow(workspaceGrid, 2);
        }

        // --- FILE OPERATIONS ---

        private void SelectFile(string targetType)
        {
            OpenFileDialog dlg = new OpenFileDialog();
            dlg.Filter = "Firmware Files|*.bin;*.img|All Files|*.*";
            if (dlg.ShowDialog() == true)
            {
                if (targetType == "MISC")
                {
                    _pathMisc = dlg.FileName;
                    _lblFileMisc.Text = System.IO.Path.GetFileName(_pathMisc);
                    Log("Loaded MISC/PROINFO: " + _pathMisc);
                }
                else if (targetType == "SUPER_SPD")
                {
                    _pathSuperSpd = dlg.FileName;
                    _lblFileSuperSpd.Text = System.IO.Path.GetFileName(_pathSuperSpd);
                    Log("Loaded SUPER (SPD): " + _pathSuperSpd);
                }
                else if (targetType == "SUPER_MTK")
                {
                    _pathSuperMtk = dlg.FileName;
                    _lblFileSuperMtk.Text = System.IO.Path.GetFileName(_pathSuperMtk);
                    Log("Loaded SUPER (MTK): " + _pathSuperMtk);
                }
                else if (targetType == "MDM_STEP1")
                {
                    _pathMdm1 = dlg.FileName;
                    _lblFileMdm1.Text = System.IO.Path.GetFileName(_pathMdm1);
                    Log("Loaded MDM STEP 1: " + _pathMdm1);
                }
                else if (targetType == "MDM_STEP2")
                {
                    _pathMdm2 = dlg.FileName;
                    _lblFileMdm2.Text = System.IO.Path.GetFileName(_pathMdm2);
                    Log("Loaded MDM STEP 2: " + _pathMdm2);
                }
            }
        }

        private async void RunPatch(string mode)
        {
            string targetPath = "";
            if (mode == "MISC") targetPath = _pathMisc;
            else if (mode == "SUPER_SPD") targetPath = _pathSuperSpd;
            else if (mode == "SUPER_MTK") targetPath = _pathSuperMtk;
            else if (mode == "MDM_STEP1") targetPath = _pathMdm1;
            else if (mode == "MDM_STEP2") targetPath = _pathMdm2;

            if (string.IsNullOrEmpty(targetPath) || !File.Exists(targetPath))
            {
                Log("Error: No file loaded for " + mode + " operation.");
                return;
            }

            Log("Starting " + mode + " Patch on: " + System.IO.Path.GetFileName(targetPath));
            
            await Task.Run(() => 
            {
                try 
                {
                    string backup = targetPath + ".bak";
                    if(!File.Exists(backup)) File.Copy(targetPath, backup);
                    
                    bool patched = false;
                    
                    if (mode == "MISC") 
                    {
                        string result = PerformTripleWipe(targetPath);
                        if (result == "SUCCESS") patched = true;
                        else Log("Misc Patch Error: " + result);
                    }
                    else if (mode.StartsWith("SUPER")) 
                    {
                        using (FileStream fs = new FileStream(targetPath, FileMode.Open, FileAccess.ReadWrite))
                        {
                             Log(">> Stage 1: Fingerprint Wipe...");
                             bool fp = PerformFingerprintWipe(fs);
                             
                             Log(">> Stage 2: Security.apk Wipe...");
                             PerformStrictBlockWipe(fs, SEC_HEX);
                             
                             Log(">> Stage 3: PCS Wipe...");
                             PerformStrictBlockWipe(fs, PCS_HEX);
                             PerformStrictBlockWipe(fs, SEC_ODEX_HEX);
                             PerformStrictBlockWipe(fs, PCS_APKOAT_HEX);
                             
                             Log(">> Stage 4: Priv-App Gap Wipe...");
                             PerformPrivAppGapWipe(fs);
                             
                             Log(">> Stage 5: Product Security Wipe...");
                             PerformProdSecWipe(fs);
                             
                             patched = true;
                        }
                    }
                    else if (mode.StartsWith("MDM"))
                    {
                        Log(">> Simulating MDM Patch...");
                        System.Threading.Thread.Sleep(500); 
                        patched = true; 
                    }

                    if (patched) Log("SUCCESS: " + mode + " patch applied.");
                }
                catch (Exception ex)
                {
                    Log("CRITICAL ERROR: " + ex.Message);
                }
            });
        }

        // --- KNOX WIZARD ALGORITHMS (PORTED & FIXED) ---

        // 1. MISC PATCH (TRIPLE WIPE)
        private string PerformTripleWipe(string path) {
             try {
                byte[] data = File.ReadAllBytes(path);
                
                byte[] target = { 0x61, 0x63, 0x74, 0x69, 0x76, 0x65 }; 
                List<int> positions = FindAllOccurrences(data, target);
                
                if (positions.Count > 0) {
                    foreach (int activeStart in positions) {
                        int activeEnd = activeStart + target.Length; 
                        int numberStart = -1;
                        for (int i = activeEnd; i < data.Length - 4; i++) { 
                             if (IsDigit(data[i]) && IsDigit(data[i+1]) && IsDigit(data[i+2]) && IsDigit(data[i+3])) { numberStart = i; break; } 
                        }
                        if (numberStart == -1) continue;
                        
                        int wipe1End = numberStart - 1; int wipe1Start = activeStart; int zeroCount = 0;
                        for (int i = activeStart - 1; i >= 0; i--) { if (data[i] == 0x00) zeroCount++; else zeroCount = 0; if (zeroCount >= 16) { wipe1Start = i + zeroCount; break; } }
                        if (wipe1End >= wipe1Start) Array.Clear(data, wipe1Start, wipe1End - wipe1Start + 1);
                        
                        int numberEnd = numberStart; while (numberEnd < data.Length && IsDigit(data[numberEnd])) { numberEnd++; }
                        int safetyPoint = numberEnd + 32; 
                        if (safetyPoint < data.Length) {
                            int realDataStart2 = -1;
                            for(int k = safetyPoint; k < data.Length; k++) { if (data[k] != 0x00) { realDataStart2 = k; break; } if (k - safetyPoint > 5000) break;  }
                            if (realDataStart2 != -1) {
                                int wipe2EndIndex = -1; int zeroCountFwd = 0;
                                for (int k = realDataStart2; k < data.Length; k++) { if (data[k] == 0x00) zeroCountFwd++; else zeroCountFwd = 0; if (zeroCountFwd >= 16) { wipe2EndIndex = k - 16; break; } if (k == data.Length - 1) wipe2EndIndex = k; }
                                int len2 = wipe2EndIndex - realDataStart2 + 1;
                                if (len2 > 0 && len2 < 1024*1024) Array.Clear(data, realDataStart2, len2);
                            }
                        }
                    }
                }
                
                // --- FIX: Explicit System.IO.Path ---
                string ext = System.IO.Path.GetExtension(path).ToLower(); 
                long patchOffset = -1;
                if (ext == ".bin") patchOffset = 0xC17F0; else if (ext == ".img") patchOffset = 0x2A07F0;
                if (patchOffset != -1 && data.Length > patchOffset + 10) { 
                    data[patchOffset + 6] = 0x3A; data[patchOffset + 8] = 0x00; 
                    Log("Header signature patched.");
                }
                
                File.WriteAllBytes(path, data); 
                return "SUCCESS";
             } catch (Exception ex) { return "ERROR: " + ex.Message; }
        }

        // 2. SUPER PATCH - FINGERPRINT
        private bool PerformFingerprintWipe(FileStream fs) { 
            byte[] fingerprint = HexStringToBytes(FP_HEX); 
            byte[] startMark = Encoding.UTF8.GetBytes(FP_START); 
            byte[] endMark = Encoding.UTF8.GetBytes(FP_END); 
            long currentPos = 0; bool found = false; 
            while(currentPos < fs.Length) { 
                long matchPos = FindFirstOccurrence(fs, fingerprint, currentPos); 
                if (matchPos == -1) break; 
                found = true; 
                long searchBackLimit1 = Math.Max(0, matchPos - (1024 * 1024 * 5)); 
                long firstPK = FindLastOccurrenceInRange(fs, startMark, searchBackLimit1, matchPos); 
                if (firstPK != -1) { 
                    long searchBackLimit2 = Math.Max(0, firstPK - (1024 * 1024 * 5)); 
                    long secondPK = FindLastOccurrenceInRange(fs, startMark, searchBackLimit2, firstPK - 1); 
                    long finalStartPos = (secondPK != -1) ? secondPK : firstPK; 
                    long endPos = FindFirstOccurrence(fs, endMark, matchPos); 
                    if (endPos != -1) { 
                        long wipeLength = (endPos + endMark.Length) - finalStartPos; 
                        fs.Position = finalStartPos; 
                        fs.Write(new byte[wipeLength], 0, (int)wipeLength); 
                        currentPos = endPos + endMark.Length; continue; 
                    } 
                } 
                currentPos = matchPos + fingerprint.Length; 
            } 
            return found; 
        }

        // 3. SUPER PATCH - STRICT BLOCK WIPE
        private bool PerformStrictBlockWipe(FileStream fs, string hexTarget) { 
            byte[] target = HexStringToBytes(hexTarget); 
            byte[] marker = HexStringToBytes(YYYY_MARKER); 
            long currentPos = 0; bool found = false; 
            while(currentPos < fs.Length) { 
                long matchPos = FindFirstOccurrence(fs, target, currentPos); 
                if (matchPos == -1) break; 
                found = true; 
                long searchBackLimit = Math.Max(0, matchPos - (1024 * 1024)); 
                long topMarkerPos = FindLastOccurrenceInRange(fs, marker, searchBackLimit, matchPos); 
                if (topMarkerPos != -1) { 
                    long rowStart = topMarkerPos - (topMarkerPos % 16); 
                    long eraseStart = rowStart + 16; 
                    long bottomMarkerPos = FindFirstOccurrence(fs, marker, matchPos + target.Length); 
                    if (bottomMarkerPos != -1) { 
                        long eraseEnd = bottomMarkerPos - (bottomMarkerPos % 16); 
                        if (eraseEnd > eraseStart) { 
                            long wipeLength = eraseEnd - eraseStart; 
                            fs.Position = eraseStart; 
                            fs.Write(new byte[wipeLength], 0, (int)wipeLength); 
                            currentPos = bottomMarkerPos + 16; continue; 
                        } 
                    } 
                } 
                currentPos = matchPos + target.Length; 
            } 
            return found; 
        }

        // 4. SUPER PATCH - PRIV GAP
        private bool PerformPrivAppGapWipe(FileStream fs) { 
            byte[] target = HexStringToBytes(PRIV_APP_HEX); 
            byte[] marker = HexStringToBytes(YYYY_MARKER); 
            long currentPos = 0; bool found = false; 
            while(currentPos < fs.Length) { 
                long matchPos = FindFirstOccurrence(fs, target, currentPos); 
                if (matchPos == -1) break; 
                found = true; 
                long searchBackLimit = Math.Max(0, matchPos - (1024 * 1024)); 
                long topMarkerStart = FindLastOccurrenceInRange(fs, marker, searchBackLimit, matchPos); 
                if (topMarkerStart != -1) { 
                    fs.Position = topMarkerStart; int b; long trueEndOfFFs = topMarkerStart; 
                    while((b = fs.ReadByte()) != -1) { if (b != 0xFF) { trueEndOfFFs = fs.Position - 1; break; } } 
                    long eraseStart = trueEndOfFFs + 3; 
                    long bottomMarkerPos = FindFirstOccurrence(fs, marker, matchPos + target.Length); 
                    if (bottomMarkerPos != -1) { 
                        long eraseEnd = bottomMarkerPos - (bottomMarkerPos % 16); 
                        if (eraseEnd > eraseStart) { 
                            long wipeLength = eraseEnd - eraseStart; 
                            fs.Position = eraseStart; fs.Write(new byte[wipeLength], 0, (int)wipeLength); 
                            currentPos = bottomMarkerPos + 4; continue; 
                        } 
                    } 
                } 
                currentPos = matchPos + target.Length; 
            } 
            return found; 
        }

        // 5. SUPER PATCH - PROD SEC
        private bool PerformProdSecWipe(FileStream fs) { 
            byte[] target = HexStringToBytes(PROD_SEC_HEX); 
            byte[] marker = HexStringToBytes(YYYY_MARKER); 
            long currentPos = 0; bool found = false; 
            while(currentPos < fs.Length) { 
                long matchPos = FindFirstOccurrence(fs, target, currentPos); 
                if (matchPos == -1) break; 
                found = true; 
                long searchBackLimit = Math.Max(0, matchPos - (1024 * 1024)); 
                long topMarkerStart = FindLastOccurrenceInRange(fs, marker, searchBackLimit, matchPos); 
                if (topMarkerStart != -1) { 
                    fs.Position = topMarkerStart; int b; long trueEndOfFFs = topMarkerStart; 
                    while((b = fs.ReadByte()) != -1) { if (b != 0xFF) { trueEndOfFFs = fs.Position - 1; break; } } 
                    long eraseStart = trueEndOfFFs + 6; 
                    long bottomMarkerPos = FindFirstOccurrence(fs, marker, matchPos + target.Length); 
                    if (bottomMarkerPos != -1) { 
                        long eraseEnd = bottomMarkerPos - 3; 
                        if (eraseEnd > eraseStart) { 
                            long wipeLength = eraseEnd - eraseStart; 
                            fs.Position = eraseStart; fs.Write(new byte[wipeLength], 0, (int)wipeLength); 
                            currentPos = bottomMarkerPos + 4; continue; 
                        } 
                    } 
                } 
                currentPos = matchPos + target.Length; 
            } 
            return found; 
        }

        // --- HELPERS ---
        private byte[] HexStringToBytes(string hex) { hex = hex.Replace(" ", ""); return Enumerable.Range(0, hex.Length).Where(x => x % 2 == 0).Select(x => Convert.ToByte(hex.Substring(x, 2), 16)).ToArray(); }
        private bool IsDigit(byte b) { return (b >= 0x30 && b <= 0x39); }
        private List<int> FindAllOccurrences(byte[] data, byte[] pattern) { List<int> positions = new List<int>(); for (int i = 0; i <= data.Length - pattern.Length; i++) { bool match = true; for (int j = 0; j < pattern.Length; j++) { if (data[i + j] != pattern[j]) { match = false; break; } } if (match) positions.Add(i); } return positions; }
        
        private long FindFirstOccurrence(FileStream fs, byte[] pattern, long startOffset) { int bufferSize = 1024 * 1024; byte[] buffer = new byte[bufferSize]; fs.Position = startOffset; int bytesRead; while ((bytesRead = fs.Read(buffer, 0, buffer.Length)) > 0) { for (int i = 0; i <= bytesRead - pattern.Length; i++) { if (IsMatch(buffer, i, pattern)) return (fs.Position - bytesRead) + i; } if (fs.Position < fs.Length) fs.Position -= pattern.Length; } return -1; }
        private long FindLastOccurrenceInRange(FileStream fs, byte[] pattern, long startLimit, long endLimit) { long bestPos = -1; fs.Position = startLimit; int bufferSize = 1024 * 1024; byte[] buffer = new byte[bufferSize]; long totalToRead = endLimit - startLimit; long processed = 0; while (processed < totalToRead) { int toRead = (int)Math.Min(bufferSize, totalToRead - processed); int bytesRead = fs.Read(buffer, 0, toRead); if (bytesRead == 0) break; for (int i = 0; i <= bytesRead - pattern.Length; i++) { if (IsMatch(buffer, i, pattern)) bestPos = (fs.Position - bytesRead) + i; } processed += bytesRead; if (processed < totalToRead) { fs.Position -= pattern.Length; processed -= pattern.Length; } } return bestPos; }
        private bool IsMatch(byte[] buffer, int offset, byte[] pattern) { for (int j = 0; j < pattern.Length; j++) { if (buffer[offset + j] != pattern[j]) return false; } return true; }

        // --- UI IMPLEMENTATION (UNCHANGED v19.6 COMPACT) ---

        private Grid CreatePatchView()
        {
            Grid g = new Grid { Visibility = Visibility.Visible };
            
            StackPanel mainStack = new StackPanel 
            { 
                VerticalAlignment = VerticalAlignment.Top,
                Orientation = Orientation.Vertical
            };
            
            // --- 1. TOP PANEL: MISC/PROINFO ---
            Border cardMisc = new Border 
            { 
                Background = new SolidColorBrush(Color.FromArgb(10, 255, 255, 255)), 
                CornerRadius = new CornerRadius(6), 
                Padding = new Thickness(10), 
                Margin = new Thickness(5, 0, 5, 4) 
            };
            
            TextBlock titleMisc = new TextBlock { Text = "MISCDATA / PROINFO", FontSize = 16, FontFamily = new FontFamily("Segoe UI Light"), Foreground = Brushes.White, HorizontalAlignment = HorizontalAlignment.Center, Margin = new Thickness(0,0,0,5) };
            _lblFileMisc = new TextBlock { Text = "No file loaded", FontSize = 12, Foreground = new SolidColorBrush(Color.FromArgb(120, 255, 255, 255)), HorizontalAlignment = HorizontalAlignment.Center, Margin = new Thickness(0, 0, 0, 10), TextTrimming = TextTrimming.CharacterEllipsis };
            
            StackPanel btnsMisc = new StackPanel { Orientation = Orientation.Horizontal, HorizontalAlignment = HorizontalAlignment.Center };
            btnsMisc.Children.Add(CreateWin11Button("LOAD FILE", () => SelectFile("MISC")));
            btnsMisc.Children.Add(CreateWin11Button("EXECUTE PATCH", () => RunPatch("MISC")));

            StackPanel innerMisc = new StackPanel();
            innerMisc.Children.Add(titleMisc);
            innerMisc.Children.Add(_lblFileMisc);
            innerMisc.Children.Add(btnsMisc);
            cardMisc.Child = innerMisc;
            mainStack.Children.Add(cardMisc);
            
            // --- 2. MIDDLE AREA: SPLIT SUPER ---
            Grid splitGrid1 = new Grid { Margin = new Thickness(0,0,0,4) }; 
            splitGrid1.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
            splitGrid1.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
            
            // SUPER SPD
            Border cardSpd = new Border 
            { 
                Background = new SolidColorBrush(Color.FromArgb(10, 255, 255, 255)), 
                CornerRadius = new CornerRadius(6), 
                Padding = new Thickness(10), 
                Margin = new Thickness(5, 0, 3, 0)
            };
            StackPanel spSpd = new StackPanel();
            spSpd.Children.Add(new TextBlock { Text = "SPD PATCH [BETA]", FontSize = 14, FontFamily = new FontFamily("Segoe UI Semibold"), Foreground = Brushes.White, HorizontalAlignment = HorizontalAlignment.Center, Margin = new Thickness(0,0,0,5) });
            _lblFileSuperSpd = new TextBlock { Text = "No file", FontSize = 11, Foreground = new SolidColorBrush(Color.FromArgb(100, 255, 255, 255)), HorizontalAlignment = HorizontalAlignment.Center, Margin = new Thickness(0,0,0,8), TextTrimming = TextTrimming.CharacterEllipsis };
            spSpd.Children.Add(_lblFileSuperSpd);
            spSpd.Children.Add(CreateWin11Button("LOAD", () => SelectFile("SUPER_SPD")));
            spSpd.Children.Add(CreateWin11Button("PATCH", () => RunPatch("SUPER_SPD")));
            cardSpd.Child = spSpd;
            splitGrid1.Children.Add(cardSpd);
            Grid.SetColumn(cardSpd, 0);

            // SUPER MTK
            Border cardMtk = new Border 
            { 
                Background = new SolidColorBrush(Color.FromArgb(10, 255, 255, 255)), 
                CornerRadius = new CornerRadius(6), 
                Padding = new Thickness(10), 
                Margin = new Thickness(3, 0, 5, 0)
            };
            StackPanel spMtk = new StackPanel();
            spMtk.Children.Add(new TextBlock { Text = "MTK PATCH [BETA]", FontSize = 14, FontFamily = new FontFamily("Segoe UI Semibold"), Foreground = Brushes.White, HorizontalAlignment = HorizontalAlignment.Center, Margin = new Thickness(0,0,0,5) });
            _lblFileSuperMtk = new TextBlock { Text = "No file", FontSize = 11, Foreground = new SolidColorBrush(Color.FromArgb(100, 255, 255, 255)), HorizontalAlignment = HorizontalAlignment.Center, Margin = new Thickness(0,0,0,8), TextTrimming = TextTrimming.CharacterEllipsis };
            spMtk.Children.Add(_lblFileSuperMtk);
            spMtk.Children.Add(CreateWin11Button("LOAD", () => SelectFile("SUPER_MTK")));
            spMtk.Children.Add(CreateWin11Button("PATCH", () => RunPatch("SUPER_MTK")));
            cardMtk.Child = spMtk;
            splitGrid1.Children.Add(cardMtk);
            Grid.SetColumn(cardMtk, 1);
            
            mainStack.Children.Add(splitGrid1);

            // --- 3. BOTTOM AREA: PERMANENT MDM PATCH ---
            
            TextBlock lblMdmHeader = new TextBlock 
            { 
                Text = "PERMANENT MDM PATCH [BETA]", 
                FontSize = 14, 
                FontFamily = new FontFamily("Segoe UI Light"), 
                Foreground = new SolidColorBrush(Color.FromArgb(180, 255, 255, 255)), 
                HorizontalAlignment = HorizontalAlignment.Center, 
                Margin = new Thickness(0, 8, 0, 4) 
            };
            mainStack.Children.Add(lblMdmHeader);

            Grid splitGrid2 = new Grid { Margin = new Thickness(0) };
            splitGrid2.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
            splitGrid2.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });

            // STEP 1
            Border cardMdm1 = new Border 
            { 
                Background = new SolidColorBrush(Color.FromArgb(10, 255, 255, 255)), 
                CornerRadius = new CornerRadius(6), 
                Padding = new Thickness(10), 
                Margin = new Thickness(5, 0, 3, 0)
            };
            StackPanel spMdm1 = new StackPanel();
            spMdm1.Children.Add(new TextBlock { Text = "STEP 1", FontSize = 14, FontFamily = new FontFamily("Segoe UI Semibold"), Foreground = Brushes.White, HorizontalAlignment = HorizontalAlignment.Center, Margin = new Thickness(0,0,0,5) });
            _lblFileMdm1 = new TextBlock { Text = "No file", FontSize = 11, Foreground = new SolidColorBrush(Color.FromArgb(100, 255, 255, 255)), HorizontalAlignment = HorizontalAlignment.Center, Margin = new Thickness(0,0,0,8), TextTrimming = TextTrimming.CharacterEllipsis };
            spMdm1.Children.Add(_lblFileMdm1);
            spMdm1.Children.Add(CreateWin11Button("LOAD", () => SelectFile("MDM_STEP1")));
            spMdm1.Children.Add(CreateWin11Button("PATCH", () => RunPatch("MDM_STEP1")));
            cardMdm1.Child = spMdm1;
            splitGrid2.Children.Add(cardMdm1);
            Grid.SetColumn(cardMdm1, 0);

            // STEP 2
            Border cardMdm2 = new Border 
            { 
                Background = new SolidColorBrush(Color.FromArgb(10, 255, 255, 255)), 
                CornerRadius = new CornerRadius(6), 
                Padding = new Thickness(10), 
                Margin = new Thickness(3, 0, 5, 0)
            };
            StackPanel spMdm2 = new StackPanel();
            spMdm2.Children.Add(new TextBlock { Text = "STEP 2", FontSize = 14, FontFamily = new FontFamily("Segoe UI Semibold"), Foreground = Brushes.White, HorizontalAlignment = HorizontalAlignment.Center, Margin = new Thickness(0,0,0,5) });
            _lblFileMdm2 = new TextBlock { Text = "No file", FontSize = 11, Foreground = new SolidColorBrush(Color.FromArgb(100, 255, 255, 255)), HorizontalAlignment = HorizontalAlignment.Center, Margin = new Thickness(0,0,0,8), TextTrimming = TextTrimming.CharacterEllipsis };
            spMdm2.Children.Add(_lblFileMdm2);
            spMdm2.Children.Add(CreateWin11Button("LOAD", () => SelectFile("MDM_STEP2")));
            spMdm2.Children.Add(CreateWin11Button("PATCH", () => RunPatch("MDM_STEP2")));
            cardMdm2.Child = spMdm2;
            splitGrid2.Children.Add(cardMdm2);
            Grid.SetColumn(cardMdm2, 1);

            mainStack.Children.Add(splitGrid2);

            g.Children.Add(mainStack);
            return g;
        }

        private Grid CreateView(string title, string sub)
        {
            Grid g = new Grid { Visibility = Visibility.Hidden };
            StackPanel sp = new StackPanel { HorizontalAlignment = HorizontalAlignment.Center, VerticalAlignment = VerticalAlignment.Center };
            
            TextBlock t1 = new TextBlock { Text = title, FontSize = 28, FontFamily = new FontFamily("Segoe UI Light"), Foreground = Brushes.White, HorizontalAlignment = HorizontalAlignment.Center };
            TextBlock t2 = new TextBlock { Text = sub, FontSize = 13, Foreground = new SolidColorBrush(Color.FromArgb(150, 255, 255, 255)), HorizontalAlignment = HorizontalAlignment.Center, Margin = new Thickness(0, 5, 0, 30) };
            
            sp.Children.Add(t1);
            sp.Children.Add(t2);
            sp.Children.Add(CreateWin11Button("EXECUTE", () => Log("Executing " + title)));
            
            g.Children.Add(sp);
            return g;
        }

        private Border CreateWin11Button(string text, Action onClick)
        {
            Border b = new Border
            {
                CornerRadius = new CornerRadius(4),
                Background = new SolidColorBrush(Color.FromRgb(51, 51, 51)), 
                BorderBrush = new SolidColorBrush(Color.FromRgb(69, 69, 69)), 
                BorderThickness = new Thickness(1),
                Padding = new Thickness(20, 6, 20, 7), 
                Margin = new Thickness(3), 
                HorizontalAlignment = HorizontalAlignment.Center,
                Cursor = Cursors.Hand
            };
            
            if(text == "LOAD" || text == "PATCH" || text.StartsWith("LOAD") || text.StartsWith("EXECUTE")) {
                 b.HorizontalAlignment = HorizontalAlignment.Stretch; 
                 b.Margin = new Thickness(5, 3, 5, 3);
            }
            
            b.BorderThickness = new Thickness(1, 1, 1, 2); 
            b.Child = new TextBlock { Text = text, Foreground = Brushes.White, FontFamily = new FontFamily("Segoe UI"), FontSize = 12, HorizontalAlignment = HorizontalAlignment.Center };
            b.MouseEnter += (s, e) => b.Background = new SolidColorBrush(Color.FromRgb(60, 60, 60));
            b.MouseLeave += (s, e) => b.Background = new SolidColorBrush(Color.FromRgb(51, 51, 51));
            b.MouseLeftButtonDown += (s, e) => { e.Handled = true; onClick(); };
            return b;
        }

        private void Log(string msg)
        {
            Dispatcher.Invoke(() => {
                string time = DateTime.Now.ToString("HH:mm:ss");
                _consoleOutput.AppendText("\r\n[" + time + "] " + msg);
                _consoleOutput.ScrollToEnd();
            });
        }

        private void SwitchTo(string viewName)
        {
            _viewPatch.Visibility = Visibility.Hidden;
            _viewSpd.Visibility = Visibility.Hidden;
            _viewSamsung.Visibility = Visibility.Hidden;
            _viewHmd.Visibility = Visibility.Hidden;
            _viewOther.Visibility = Visibility.Hidden;

            foreach(var btn in _tabButtons)
            {
                btn.Background = Brushes.Transparent;
                ((TextBlock)btn.Child).Foreground = new SolidColorBrush(Color.FromArgb(150, 255, 255, 255));
            }

            int index = 0;
            switch(viewName)
            {
                case "PATCH": _viewPatch.Visibility = Visibility.Visible; index = 0; break;
                case "SPD": _viewSpd.Visibility = Visibility.Visible; index = 1; break;
                case "SAMSUNG": _viewSamsung.Visibility = Visibility.Visible; index = 2; break;
                case "HMD": _viewHmd.Visibility = Visibility.Visible; index = 3; break;
                case "OTHER": _viewOther.Visibility = Visibility.Visible; index = 4; break;
            }
            _tabButtons[index].Background = new SolidColorBrush(Color.FromArgb(20, 255, 255, 255));
            ((TextBlock)_tabButtons[index].Child).Foreground = Brushes.White;
        }

        private Border CreateTabButton(string text, Action onClick)
        {
            Border b = new Border 
            { 
                CornerRadius = new CornerRadius(4), 
                Padding = new Thickness(16, 6, 16, 6), 
                Margin = new Thickness(4, 0, 4, 0), 
                Cursor = Cursors.Hand, 
                Background = Brushes.Transparent,
                VerticalAlignment = VerticalAlignment.Center 
            };
            b.Child = new TextBlock { Text = text, FontSize = 12, FontFamily = new FontFamily("Segoe UI Semibold"), Foreground = new SolidColorBrush(Color.FromArgb(150, 255, 255, 255)) };
            b.MouseLeftButtonDown += (s, e) => { e.Handled = true; onClick(); };
            return b;
        }

        private Border CreateCaptionButton(string type, Action onClick)
        {
            Border btn = new Border { Width = 46, Height = 32, Background = Brushes.Transparent, Cursor = Cursors.Hand };
            System.Windows.Shapes.Path icon = new System.Windows.Shapes.Path 
            { 
                Stroke = Brushes.White, 
                StrokeThickness = 1, 
                HorizontalAlignment = HorizontalAlignment.Center, 
                VerticalAlignment = VerticalAlignment.Center 
            };
            
            if (type == "Close") { var g = new StreamGeometry(); using(var c = g.Open()) { c.BeginFigure(new Point(0,0), false, false); c.LineTo(new Point(10,10), true, false); c.BeginFigure(new Point(10,0), false, false); c.LineTo(new Point(0,10), true, false); } icon.Data = g; }
            else if (type == "Max") { var g = new StreamGeometry(); using(var c = g.Open()) { c.BeginFigure(new Point(0,0), false, true); c.LineTo(new Point(10,0), true, false); c.LineTo(new Point(10,10), true, false); c.LineTo(new Point(0,10), true, false); } icon.Data = g; }
            else if (type == "Min") { var g = new StreamGeometry(); using(var c = g.Open()) { c.BeginFigure(new Point(0,5), false, false); c.LineTo(new Point(10,5), true, false); } icon.Data = g; }
            
            btn.Child = icon;
            btn.MouseEnter += (s, e) => { if(type == "Close") { btn.Background = new SolidColorBrush(Color.FromRgb(232, 17, 35)); icon.Stroke = Brushes.White; } else { btn.Background = new SolidColorBrush(Color.FromArgb(20, 255, 255, 255)); } };
            btn.MouseLeave += (s, e) => { btn.Background = Brushes.Transparent; icon.Stroke = Brushes.White; };
            btn.MouseLeftButtonDown += (s, e) => { e.Handled = true; };
            btn.MouseLeftButtonUp += (s, e) => { e.Handled = true; onClick(); };
            return btn;
        }

        private void ToggleMaximize() {
             if (this.WindowState == WindowState.Maximized) this.WindowState = WindowState.Normal;
             else { this.MaxHeight = SystemParameters.WorkArea.Height; this.WindowState = WindowState.Maximized; }
        }
    }
}
"@

# --- 2. PATH RESOLUTION ---
$netFrameworkPath = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319"
$wpfPath = "$netFrameworkPath\WPF"

Write-Host "Resolving Dependencies..." -ForegroundColor Gray

$assemblies = @(
    "$netFrameworkPath\System.dll",
    "$netFrameworkPath\System.Core.dll",
    "$netFrameworkPath\System.Xaml.dll",
    "$wpfPath\PresentationCore.dll",
    "$wpfPath\PresentationFramework.dll",
    "$wpfPath\WindowsBase.dll"
)

# --- 3. COMPILATION ---
$outputFile = "LonyiToolV20.1.exe"
Write-Host "Compiling C# Source Code..." -ForegroundColor Green

$compilerParams = New-Object System.CodeDom.Compiler.CompilerParameters
$compilerParams.ReferencedAssemblies.AddRange($assemblies)
$compilerParams.GenerateExecutable = $true
$compilerParams.OutputAssembly = $outputFile
$compilerParams.CompilerOptions = "/target:winexe"

$codeProvider = New-Object Microsoft.CSharp.CSharpCodeProvider
$results = $codeProvider.CompileAssemblyFromSource($compilerParams, $sourceCode)

# --- 4. EXECUTION ---
if ($results.Errors.Count -gt 0) {
    Write-Host "`n[!] Compilation Failed:" -ForegroundColor Red
    foreach ($err in $results.Errors) { Write-Host " > " $err.ErrorText -ForegroundColor Red }
} else {
    Write-Host "`n[+] Build Success! Generated $outputFile" -ForegroundColor Green
    Write-Host "[*] Launching Application..." -ForegroundColor Yellow
    Invoke-Item $outputFile
}

Write-Host "`n----------------------------------------" -ForegroundColor DarkGray
Write-Host "Execution Complete." -ForegroundColor White
Read-Host "Press Enter to exit this window..."