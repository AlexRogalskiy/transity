module Transity.Xlsx where

import Prelude
  ( class Eq, bind, map, max, pure, show, Unit
  , (#), ($), (+), (-), (/), (/=), (<#>), (<>), (==), (>=), (>>=), (>>>)
  )

import Data.Array (sort)
import Data.Function.Uncurried (Fn3, runFn3)
import Data.Maybe (Maybe(..))
import Data.String (joinWith)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)

import Transity.Data.Ledger (Ledger, getEntries)


newtype FileEntry = FileEntry
  { path :: String
  , content :: String
  }


foreign import writeToZipImpl
  :: forall a. Fn3 (Maybe a) (Maybe String) (Array FileEntry) (EffectFnAff Unit)

writeToZip :: Maybe String -> Array FileEntry -> Aff Unit
writeToZip outPath files = fromEffectFnAff $
  runFn3 writeToZipImpl Nothing outPath files


entriesAsXml :: Ledger -> Maybe String
entriesAsXml ledger = do
  entries <- getEntries ledger

  pure $ entries
    # sort
    <#> (\cells -> "<row>\n"
      <> (cells
        <#> (\cell ->
                "  <c t=\"inlineStr\"><is><t>"
                <> cell
                <> "</t></is></c>"
            )
        # joinWith "\n")
      <> "\n</row>")
    # joinWith "\n"


contentTypesContent :: String
contentTypesContent = """<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default
    ContentType="application/xml"
    Extension="xml"
  />
  <Default
    ContentType="application/vnd.openxmlformats-package.relationships+xml"
    Extension="rels"
  />
  <Override
    ContentType="application/vnd.openxmlformats-package.relationships+xml"
    PartName="/_rels/.rels"
  />
  <Override
    ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"
    PartName="/xl/workbook.xml"
  />
  <Override
    ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"
    PartName="/xl/styles.xml"
  />
  <Override
    ContentType="application/vnd.openxmlformats-package.relationships+xml"
    PartName="/xl/_rels/workbook.xml.rels"
  />
  <Override
    ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"
    PartName="/xl/worksheets/sheet1.xml"
  />
  <Override
    ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"
    PartName="/xl/sharedStrings.xml"
  />
  <Override
    ContentType="application/vnd.openxmlformats-package.core-properties+xml"
    PartName="/docProps/core.xml"
  />
  <Override
    ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"
    PartName="/docProps/app.xml"
  />
</Types>
"""


relsContent :: String
relsContent = """<?xml version="1.0" encoding="UTF-8"?>
<Relationships
  xmlns="http://schemas.openxmlformats.org/package/2006/relationships"
>
  <Relationship
    Id="rId1"
    Target="xl/workbook.xml"
    Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"
  />
  <Relationship
    Id="rId2"
    Target="docProps/core.xml"
    Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties"
  />
  <Relationship
    Id="rId3"
    Target="docProps/app.xml"
    Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties"
  />
</Relationships>
"""


appContent :: String
appContent = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties
  xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"
>
  <Application>Transity</Application>
  <AppVersion>0.0</AppVersion>
</Properties>
"""


-- TODO: Implement correct timestamp
now :: String
now = "2021-01-01T00:00:00Z"


coreContent :: String
coreContent = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties
  xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
>
  <dc:creator>Transity</dc:creator>
  <cp:lastModifiedBy>Transity</cp:lastModifiedBy>
  <dc:description>
    All transfers of journal created with Transity
  </dc:description>
  <dcterms:created xsi:type="dcterms:W3CDTF">"""
    <> now <>
  """</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">"""
    <> now <>
  """</dcterms:modified>
</cp:coreProperties>
"""


xlRelsContent :: String
xlRelsContent = """<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship
    Id="rId1"
    Target="worksheets/sheet1.xml"
    Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet"
  />
  <Relationship
    Id="rId2"
    Target="styles.xml"
    Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles"
  />
  <Relationship
    Id="rId3"
    Target="sharedStrings.xml"
    Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings"
  />
</Relationships>
"""


sharedStrContent :: String
sharedStrContent = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<sst
  count="0"
  uniqueCount="0"
  xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
>
</sst>
"""


-- Mandatory (otherwise neither Excel nor Apple Numbers can open it)
-- More information: https://stackoverflow.com/a/26062365/1850340
stylesContent :: String
stylesContent = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <fonts count="1">
    <font>
      <sz val="10"/>
      <name val="Arial"/>
      <family val="2"/>
    </font>
  </fonts>
  <fills count="2">
    <fill>
      <patternFill patternType="none"/>
    </fill>
    <fill>
      <patternFill patternType="gray125"/>
    </fill>
  </fills>
  <borders count="1">
    <border>
      <left/>
      <right/>
      <top/>
      <bottom/>
      <diagonal/>
    </border>
  </borders>
  <cellStyleXfs count="2">
    <xf
      borderId="0"
      fillId="0"
      fontId="0"
      numFmtId="0"
    />
    <xf
      borderId="0"
      fillId="0"
      fontId="0"
      numFmtId="0"
    />
  </cellStyleXfs>
</styleSheet>
"""


workbookContent :: String
workbookContent = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook
  xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
>
  <sheets>
    <sheet
      name="Sheet1"
      r:id="rId1"
      sheetId="1"
    />
  </sheets>
</workbook>
"""


rowsToSheet:: String -> String
rowsToSheet rows = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet
  xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:x14="http://schemas.microsoft.com/office/spreadsheetml/2009/9/main"
  xmlns:xdr="http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing"
>
  <sheetPr filterMode="false">
    <pageSetUpPr fitToPage="false"/>
  </sheetPr>
  <dimension ref="A1:C2"/>
  <sheetViews>
    <sheetView
      colorId="64"
      defaultGridColor="true"
      rightToLeft="false"
      showFormulas="false"
      showGridLines="true"
      showOutlineSymbols="true"
      showRowColHeaders="true"
      showZeros="true"
      tabSelected="true"
      topLeftCell="A1"
      view="normal"
      workbookViewId="0"
      zoomScale="100"
      zoomScaleNormal="100"
      zoomScalePageLayoutView="100"
    >
      <selection
        activeCell="C4"
        activeCellId="0"
        pane="topLeft"
        sqref="C4"
      />
    </sheetView>
  </sheetViews>
  <sheetFormatPr
    defaultColWidth="11.53515625"
    defaultRowHeight="12.8"
    outlineLevelCol="0"
    outlineLevelRow="0"
    zeroHeight="false"
  />
  <sheetData>
""" <> rows <> """
  </sheetData>
  <printOptions
    gridLines="false"
    gridLinesSet="true"
    headings="false"
    horizontalCentered="false"
    verticalCentered="false"
  />
  <pageMargins
    bottom="1.05277777777778"
    footer="0.7875"
    header="0.7875"
    left="0.7875"
    right="0.7875"
    top="1.05277777777778"
  />
  <pageSetup
    blackAndWhite="false"
    cellComments="none"
    copies="1"
    draft="false"
    firstPageNumber="1"
    fitToHeight="1"
    fitToWidth="1"
    horizontalDpi="300"
    orientation="portrait"
    pageOrder="downThenOver"
    paperSize="9"
    scale="100"
    useFirstPageNumber="true"
    verticalDpi="300"
  />
  <headerFooter differentFirst="false" differentOddEven="false">
    <oddHeader>
      &amp;C&amp;&quot;Times New Roman,Regular&quot;&amp;12&amp;A
    </oddHeader>
    <oddFooter>
      &amp;C&amp;&quot;Times New Roman,Regular&quot;&amp;12Page &amp;P
    </oddFooter>
  </headerFooter>
</worksheet>
"""


entriesAsXlsx :: Ledger -> Array FileEntry
entriesAsXlsx ledger = do
  case entriesAsXml ledger of
    Nothing -> []
    Just rowsString ->
      [ FileEntry { path: "[Content_Types].xml", content: contentTypesContent }
      , FileEntry { path: "_rels/.rels", content: relsContent }
      , FileEntry { path: "docProps/app.xml", content: appContent }
      , FileEntry { path: "docProps/core.xml", content: coreContent }
      , FileEntry { path: "xl/_rels/workbook.xml.rels", content: xlRelsContent }
      , FileEntry { path: "xl/sharedStrings.xml", content: sharedStrContent }
      , FileEntry { path: "xl/styles.xml", content: stylesContent }
      , FileEntry { path: "xl/workbook.xml", content: workbookContent }
      , FileEntry
          { path: "xl/worksheets/sheet1.xml"
          , content: rowsToSheet rowsString
          }
      ]


