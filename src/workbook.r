########################################################################################
wb <- openxlsx::createWorkbook(title = "FEBR Esquema de Metadados v3")
sheet <- c("LEIAME", "Metadados de Citação", "Metadados Geoespaciais")
openxlsx::addWorksheet(wb = wb, sheet = sheet[1], tabColour = "red")
openxlsx::addWorksheet(wb = wb, sheet = sheet[2])
openxlsx::addWorksheet(wb = wb, sheet = sheet[3])
headerStyle <- openxlsx::createStyle(textDecoration = "bold", locked = TRUE, fgFill = "gray")

dataverse <- read.table("defs/dataverse.txt", header = TRUE, stringsAsFactors = FALSE)

# Planilha 'LEIAME'
readme <- c(
  toupper("Repositório Brasileiro Livre para Dados Abertos do Solo"), "FEBR Modelo de Conjunto de Dados v3",
  "", "DIRETRIZES DE PREENCHIMENTO",
  paste0("1. Preencha a planilha ", sheet[2], " com a identificação do conjunto de dados e seus autores."),
  paste0("2. Informe os dados do contexto espacial do conjunto de dados na planilha ", sheet[3], "."),
  ""
)
openxlsx::writeData(wb = wb, sheet = sheet[1], x = readme)
openxlsx::addStyle(
  wb = wb, sheet = sheet[1],
  rows = 1:length(readme), cols = 1:15, gridExpand = TRUE, stack = TRUE,
  style = openxlsx::createStyle(fgFill = "lightgreen", textDecoration = "bold"))

# Planilha 'Metadados de citação'
citation <- dataverse[dataverse$metadatablock == "citation", ]
citation <- citation[c("schema", "metadatablock_id", "name", "title", "description")]
citation <- cbind(citation, valor1 = "", valor2 = "", valor3 = "", valor4 = "", valorN = "")
openxlsx::writeData(
  wb = wb, sheet = sheet[2],
  x = citation[c(1:4, 6:ncol(citation))], headerStyle = headerStyle)
openxlsx::setColWidths(wb = wb, sheet = sheet[2], cols = 1:3, hidden = TRUE) # hide first three columns
openxlsx::setColWidths(wb = wb, sheet = sheet[2], cols = 5:ncol(citation) - 1, widths = "55")
openxlsx::addStyle(
  wb = wb, sheet = sheet[2], cols = 1:4, rows = 1:nrow(citation) + 1, gridExpand = TRUE, stack = TRUE,
  style = openxlsx::createStyle(fgFill = "gray", textDecoration = "bold", locked = TRUE))
openxlsx::freezePane(wb = wb, sheet = sheet[2], firstActiveRow = 2, firstActiveCol = 5)
for (i in seq_along(citation$description)) {
  openxlsx::writeComment(
    wb = wb, sheet = sheet[2],
    col = 4, row = i + 1,
    comment = openxlsx::createComment(citation$description[i], visible = FALSE))
}

# Planilha 'geospatial metadata'
geospatial <- dataverse[dataverse$metadatablock == "geospatial", ]
geospatial <- geospatial[c("schema", "metadatablock_id", "name", "title", "description")]
geospatial <- cbind(geospatial, valor1 = "", valor2 = "", valor3 = "", valor4 = "", valorN = "")
openxlsx::writeData(
  wb = wb, sheet = sheet[3],
  x = geospatial[c(1:4, 6:ncol(geospatial))], headerStyle = headerStyle)
openxlsx::setColWidths(wb = wb, sheet = sheet[3], cols = 1:3, hidden = TRUE) # hide first three columns
openxlsx::setColWidths(wb = wb, sheet = sheet[3], cols = 5:ncol(geospatial) - 1, widths = "55")
openxlsx::addStyle(
  wb = wb, sheet = sheet[3], cols = 1:4, rows = 1:nrow(geospatial) + 1, gridExpand = TRUE, stack = TRUE,
  style = openxlsx::createStyle(fgFill = "gray", textDecoration = "bold", locked = TRUE))
openxlsx::freezePane(wb = wb, sheet = sheet[3], firstActiveRow = 2, firstActiveCol = 5)
for (i in seq_along(geospatial$description)) {
  openxlsx::writeComment(
    wb = wb, sheet = sheet[3],
    col = 4, row = i + 1,
    comment = openxlsx::createComment(geospatial$description[i], visible = FALSE))
}

# Criar planilha 'identificacao'
# Quadro colunas são usadas:
# schema: nome do esquema de metadados (Dataverse v4.x)
# metadatablock_id: bloco de metadados (citation, geoespatial)
# name: nome (código) do metadado
# title: título do metadado
# description: descrição do metadado, usado como comentário de ajuda na planilha
wb$styles$fonts <- sub("Calibri", "Inconsolata", wb$styles$fonts)
openxlsx::saveWorkbook(wb = wb, file = "public/workbook.xlsx", overwrite = TRUE)
