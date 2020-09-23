########################################################################################
# Planilha 'citacao'
# Criar planilha 'identificacao'
# Quadro colunas são usadas:
# schema: nome do esquema de metadados (Dataverse v4.x)
# metadatablock_id: bloco de metadados (citation, geoespatial)
# name: nome (código) do metadado
# title: título do metadado
# description: descrição do metadado, usado como comentário de ajuda na planilha
wb <- openxlsx::createWorkbook(title = "FEBR Esquema de Metadados v3")
openxlsx::addWorksheet(wb, "identificacao")
openxlsx::writeData(wb = wb, sheet = 1, x = metadatablock[c("schema", "metadatablock_id", "name", "title")])
for (i in seq_along(metadatablock$description)) {
  openxlsx::writeComment(
    wb = wb, sheet = "identificacao", col = 4, row = i + 1,
    comment = openxlsx::createComment(metadatablock$description[i], visible = FALSE))
}
openxlsx::saveWorkbook(wb = wb, file = "res/identificacao.xlsx", overwrite = TRUE)
