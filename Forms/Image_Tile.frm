VERSION 5.00
Begin VB.Form FormTile 
   AutoRedraw      =   -1  'True
   BackColor       =   &H80000005&
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   " Tile Image"
   ClientHeight    =   6525
   ClientLeft      =   -15
   ClientTop       =   225
   ClientWidth     =   11595
   BeginProperty Font 
      Name            =   "Tahoma"
      Size            =   8.25
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   435
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   773
   ShowInTaskbar   =   0   'False
   Begin PhotoDemon.pdDropDown cboTarget 
      Height          =   375
      Left            =   6240
      TabIndex        =   1
      Top             =   1680
      Width           =   5175
      _ExtentX        =   9128
      _ExtentY        =   661
   End
   Begin PhotoDemon.pdCommandBar cmdBar 
      Align           =   2  'Align Bottom
      Height          =   805
      Left            =   0
      TabIndex        =   0
      Top             =   5719
      Width           =   11592
      _ExtentX        =   20452
      _ExtentY        =   1429
      BackColor       =   14802140
   End
   Begin PhotoDemon.pdFxPreviewCtl pdFxPreview 
      Height          =   5505
      Left            =   120
      TabIndex        =   3
      Top             =   120
      Width           =   5625
      _ExtentX        =   9922
      _ExtentY        =   9710
      DisableZoomPan  =   -1  'True
   End
   Begin PhotoDemon.pdSpinner tudWidth 
      Height          =   345
      Left            =   8040
      TabIndex        =   4
      Top             =   2400
      Width           =   1200
      _ExtentX        =   2117
      _ExtentY        =   714
      Min             =   1
      Max             =   32767
      Value           =   1
   End
   Begin PhotoDemon.pdSpinner tudHeight 
      Height          =   345
      Left            =   8040
      TabIndex        =   2
      Top             =   3030
      Width           =   1200
      _ExtentX        =   2117
      _ExtentY        =   714
      Min             =   1
      Max             =   32767
      Value           =   1
   End
   Begin PhotoDemon.pdLabel lblFlatten 
      Height          =   525
      Left            =   5880
      Top             =   5160
      Visible         =   0   'False
      Width           =   5610
      _ExtentX        =   0
      _ExtentY        =   0
      Alignment       =   2
      Caption         =   "Note: this operation will flatten the image before tiling it."
      ForeColor       =   4210752
      Layout          =   1
   End
   Begin PhotoDemon.pdLabel lblWidth 
      Height          =   285
      Left            =   5880
      Top             =   2430
      Width           =   1905
      _ExtentX        =   0
      _ExtentY        =   0
      Alignment       =   1
      Caption         =   "width"
      FontSize        =   12
      ForeColor       =   4210752
   End
   Begin PhotoDemon.pdLabel lblHeight 
      Height          =   285
      Left            =   5880
      Top             =   3060
      Width           =   1980
      _ExtentX        =   0
      _ExtentY        =   0
      Alignment       =   1
      Caption         =   "height"
      FontSize        =   12
      ForeColor       =   4210752
   End
   Begin PhotoDemon.pdLabel lblWidthUnit 
      Height          =   285
      Left            =   9330
      Top             =   2430
      Width           =   2160
      _ExtentX        =   0
      _ExtentY        =   0
      Caption         =   "pixels"
      FontSize        =   12
      ForeColor       =   8421504
   End
   Begin PhotoDemon.pdLabel lblHeightUnit 
      Height          =   285
      Left            =   9330
      Top             =   3060
      Width           =   2160
      _ExtentX        =   0
      _ExtentY        =   0
      Caption         =   "pixels"
      FontSize        =   12
      ForeColor       =   8421504
   End
   Begin PhotoDemon.pdLabel lblDescription 
      Height          =   1155
      Left            =   6000
      Top             =   3720
      Width           =   5355
      _ExtentX        =   0
      _ExtentY        =   0
      Alignment       =   2
      Caption         =   ""
      ForeColor       =   4210752
      Layout          =   1
   End
   Begin PhotoDemon.pdLabel lblAmount 
      Height          =   285
      Left            =   6000
      Top             =   1320
      Width           =   5460
      _ExtentX        =   0
      _ExtentY        =   0
      Caption         =   "render tiled image using"
      FontSize        =   12
      ForeColor       =   4210752
   End
End
Attribute VB_Name = "FormTile"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'***************************************************************************
'Tile Rendering Interface
'Copyright 2012-2016 by Tanner Helland
'Created: 25/August/12
'Last updated: 24/August/13
'Last update: clean up and modernize all code; install new text up/down user controls, add command bar
'
'Render tiled images.  Options are provided for rendering to current wallpaper size, or to a custom size in either
' pixels or tiles.
'
'It should be noted that when previewing, a full-size copy of the tiled image is created.  This may cause issues when
' very large images are tiled at even bigger sizes, but so far I have been unable to crash my PC despite testing any
' number of outrageous sizes... :)
'
'All source code in this file is licensed under a modified BSD license.  This means you may use the code in your own
' projects IF you provide attribution.  For more information, please visit http://photodemon.org/about/license/
'
'***************************************************************************

Option Explicit

'Track the last type of option used; we use this to convert the text box values intelligently
Private lastTargetMode As Long

'When the combo box is changed, make the appropriate controls visible
Private Sub cboTarget_Click()

    'Suppress previewing while all the variables get set to their proper values
    cmdBar.markPreviewStatus False

    Dim iWidth As Long, iHeight As Long
    iWidth = pdImages(g_CurrentImage).Width
    iHeight = pdImages(g_CurrentImage).Height

    Select Case cboTarget.ListIndex
    
        'Wallpaper size
        Case 0
            
            'Determine the current screen size, in pixels; this is used to provide a "render to screen size" option
            Dim cScreenWidth As Long, cScreenHeight As Long
            cScreenWidth = Screen.Width / TwipsPerPixelXFix
            cScreenHeight = Screen.Height / TwipsPerPixelYFix
            
            'Add one to the displayed width and height, since we store them -1 for loops
            tudWidth.Value = cScreenWidth
            tudHeight.Value = cScreenHeight
            
            tudWidth.Enabled = False
            tudHeight.Enabled = False
            lblWidthUnit.Caption = g_Language.TranslateMessage("pixels")
            lblHeightUnit.Caption = g_Language.TranslateMessage("pixels")
        
        'Custom size (in pixels)
        Case 1
            tudWidth.Enabled = True
            tudHeight.Enabled = True
            lblWidthUnit.Caption = g_Language.TranslateMessage("pixels")
            lblHeightUnit.Caption = g_Language.TranslateMessage("pixels")
            
            'If the user was previously measuring in tiles, convert that value to pixels
            If (lastTargetMode = 2) And tudWidth.IsValid And tudHeight.IsValid Then
                tudWidth = CLng(tudWidth) * iWidth
                tudHeight = CLng(tudHeight) * iHeight
            End If
            
        'Custom size (as number of tiles)
        Case 2
            tudWidth.Enabled = True
            tudHeight.Enabled = True
            lblWidthUnit.Caption = g_Language.TranslateMessage("tiles")
            lblHeightUnit.Caption = g_Language.TranslateMessage("tiles")
            
            'Since the user will have previously been measuring in pixels, convert that value to tiles
            If tudWidth.IsValid And tudHeight.IsValid Then
                Dim xTiles As Long, yTiles As Long
                xTiles = CLng(CSng(tudWidth) / CSng(iWidth))
                yTiles = CLng(CSng(tudHeight) / CSng(iHeight))
                If xTiles < 1 Then xTiles = 1
                If yTiles < 1 Then yTiles = 1
                tudWidth = xTiles
                tudHeight = yTiles
            End If
            
    End Select
    
    'Remember this value for future conversions
    lastTargetMode = cboTarget.ListIndex

    'Re-enable previewing
    cmdBar.markPreviewStatus True

    'Finally, draw a preview
    UpdatePreview

End Sub

'This routine renders the current image to a new, tiled image (larger than the present image)
' tType is the parameter used for determining how many tiles to draw:
' 0 - current wallpaper size
' 1 - custom size, in pixels
' 2 - custom size, as number of tiles
' The other two parameters are width and height, or tiles in x and y direction
Public Sub GenerateTile(ByVal tType As Byte, Optional xTarget As Long, Optional yTarget As Long, Optional ByVal isPreview As Boolean = False)
        
    'If a selection is active, remove it.  (This is not the most elegant solution, but we can fix it at a later date.)
    If pdImages(g_CurrentImage).selectionActive Then
        pdImages(g_CurrentImage).selectionActive = False
        pdImages(g_CurrentImage).mainSelection.lockRelease
    End If
    
    If Not isPreview Then Message "Rendering tiled image..."
    
    'Create a temporary DIB to generate the tile and/or tile preview
    Dim tmpDIB As pdDIB
    Set tmpDIB = New pdDIB
    
    'Create a temporary copy of the composited image
    Dim compositeDIB As pdDIB
    Set compositeDIB = New pdDIB
    pdImages(g_CurrentImage).getCompositedImage compositeDIB, True
    
    'We need to determine a target width and height based on the input parameters
    Dim targetWidth As Long, targetHeight As Long
    
    Dim iWidth As Long, iHeight As Long
    iWidth = pdImages(g_CurrentImage).Width
    iHeight = pdImages(g_CurrentImage).Height
        
    Select Case tType
        Case 0
            'Current wallpaper size
            targetWidth = Screen.Width / TwipsPerPixelXFix
            targetHeight = Screen.Height / TwipsPerPixelYFix
        Case 1
            'Custom size
            targetWidth = xTarget
            targetHeight = yTarget
        Case 2
            'Specific number of tiles; determine the target size in pixels, accordingly
            targetWidth = (iWidth * xTarget)
            targetHeight = (iHeight * yTarget)
    End Select
    
    'Make sure the target width/height isn't too large.  (This limit could be set bigger... I haven't actually tested it to
    ' find a max upper limit.  I'm fairly certain it's only limited by available memory.)
    Dim MaxSize As Long
    MaxSize = 32767
    
    If targetWidth > MaxSize Then targetWidth = MaxSize
    If targetHeight > MaxSize Then targetHeight = MaxSize
    
    'Resize the target picture box to this new size
    tmpDIB.createBlank targetWidth, targetHeight, 32, 0
        
    'Figure out how many loop intervals we'll need in the x and y direction to fill the target size
    Dim xLoop As Long, yLoop As Long
    xLoop = CLng(CSng(targetWidth) / CSng(iWidth))
    yLoop = CLng(CSng(targetHeight) / CSng(iHeight))
    
    If Not isPreview Then SetProgBarMax xLoop
    
    'Using that loop variable, render the original image to the target picture box that many times
    Dim x As Long, y As Long
    
    For x = 0 To xLoop
    For y = 0 To yLoop
        BitBlt tmpDIB.getDIBDC, x * iWidth, y * iHeight, iWidth, iHeight, compositeDIB.getDIBDC, 0, 0, vbSrcCopy
    Next y
        If Not isPreview Then SetProgBarVal x
    Next x
    
    If Not isPreview Then
    
        SetProgBarVal xLoop
        
        'Flatten the image
        Layer_Handler.flattenImage
        pdImages(g_CurrentImage).getLayerByIndex(0).setLayerName g_Language.TranslateMessage("Tiled image")
        
        'With the tiling complete, copy the temporary DIB over the existing DIB
        pdImages(g_CurrentImage).getLayerByIndex(0).layerDIB.createFromExistingDIB tmpDIB
        
        'Erase the temporary DIB to save on memory
        tmpDIB.eraseDIB
        Set tmpDIB = Nothing
        
        'Display the new size
        pdImages(g_CurrentImage).updateSize True
        DisplaySize pdImages(g_CurrentImage)
        
        SetProgBarVal 0
        ReleaseProgressBar
        
        'Notify the parent image of the change
        pdImages(g_CurrentImage).notifyImageChanged UNDO_LAYER, 0
        pdImages(g_CurrentImage).notifyImageChanged UNDO_IMAGE
        
        'Render the image on-screen at an automatically corrected zoom
        FitOnScreen
    
        Message "Finished."
        
    Else
        pdFxPreview.SetFXImage tmpDIB
    End If

End Sub

Private Sub cmdBar_OKClick()
    Process "Tile", , buildParams(cboTarget.ListIndex, tudWidth, tudHeight), UNDO_IMAGE
End Sub

Private Sub cmdBar_RequestPreviewUpdate()
    UpdatePreview
End Sub

Private Sub cmdBar_ResetClick()
    cboTarget.ListIndex = 0
    cboTarget_Click
End Sub

Private Sub Form_Activate()
    
    'Apply translations and visual themes
    ApplyThemeAndTranslations Me
    
    'Render a preview
    cmdBar.markPreviewStatus True
    UpdatePreview
    
End Sub

Private Sub Form_Load()

    'Suspend previews until the dialog is fully initialized
    cmdBar.markPreviewStatus False
    
    'Give the preview object a copy of this image data so it can show it to the user if requested
    pdFxPreview.SetOriginalImage pdImages(g_CurrentImage).getActiveDIB()
    
    'Populate the combo box
    cboTarget.AddItem " current screen size", 0
    cboTarget.AddItem " custom image size (in pixels)", 1
    cboTarget.AddItem " specific number of tiles", 2
    cboTarget.ListIndex = 0
    
    'If the current image has more than one layer, warn the user that this action will flatten the image.
    If pdImages(g_CurrentImage).getNumOfLayers > 1 Then
        lblFlatten.Visible = True
    Else
        lblFlatten.Visible = False
    End If
    
End Sub

Private Sub Form_Unload(Cancel As Integer)
    ReleaseFormTheming Me
End Sub

'Show the user a description of how large the new, tiled image will be
Private Sub updateDescription()

    Dim iWidth As Long, iHeight As Long
    
    iWidth = pdImages(g_CurrentImage).Width
    iHeight = pdImages(g_CurrentImage).Height

    Dim xVal As Double, yVal As Double
    Dim xText As String, yText As String
    
    Dim metricText As String
    
    'Generate a descriptive string based on which tiling method will be used
    Select Case cboTarget.ListIndex
        
        'Wallpaper size
        Case 0
            xVal = tudWidth / iWidth
            yVal = tudHeight / iHeight
            xText = Format(xVal, "####0.0#")
            yText = Format(yVal, "####0.0#")
            metricText = g_Language.TranslateMessage("tiles")
            
        'Custom size (in pixels)
        Case 1
            xVal = tudWidth / iWidth
            yVal = tudHeight / iHeight
            xText = Format(xVal, "####0.0#")
            yText = Format(yVal, "####0.0#")
            metricText = g_Language.TranslateMessage("tiles")
            
        'Custom size (in tiles)
        Case 2
            xVal = tudWidth * iWidth
            yVal = tudHeight * iHeight
            xText = Format(xVal, "#####")
            yText = Format(yVal, "#####")
            metricText = g_Language.TranslateMessage("pixels")
            
    End Select
    
    lblDescription.Caption = g_Language.TranslateMessage("the new image will be %1 %3 wide by %2 %3 tall", xText, yText, metricText)

End Sub

Private Sub tudHeight_Change()
    UpdatePreview
End Sub

Private Sub tudWidth_Change()
    UpdatePreview
End Sub

Private Sub UpdatePreview()
    If cmdBar.previewsAllowed Then
        updateDescription
        GenerateTile cboTarget.ListIndex, tudWidth, tudHeight, True
    End If
End Sub

'If the user changes the position and/or zoom of the preview viewport, the entire preview must be redrawn.
Private Sub pdFxPreview_ViewportChanged()
    UpdatePreview
End Sub






