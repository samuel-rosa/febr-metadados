# citation ####

# descarregar e processar arquivo citation_br.properties
url <- 
  'https://raw.githubusercontent.com/GlobalDataverseCommunityConsortium/dataverse-language-packs/develop/pt_BR/citation_br.properties'
cite_prop <- readLines(url)[-(1:2)]
cite_prop <- lapply(cite_prop, function (x) {
  strsplit(x, split = '.', fixed = TRUE)[[1]][1:3]
})
cite_prop <- do.call(rbind, cite_prop)
tmp <- lapply(cite_prop[, 3], function (x) {
  strsplit(x, split = '=', fixed = TRUE)[[1]][1:2]
})
tmp <- do.call(rbind, tmp)
cite_prop <- cbind(cite_prop[, 1:2], tmp)
cite_prop <- cite_prop[cite_prop[, 1] == 'datasetfieldtype', -1]
cite_prop <- cbind(
  cite_prop[cite_prop[, 2] == 'title', c(1, 3)],
  cite_prop[cite_prop[, 2] == 'description', 3],
  cite_prop[cite_prop[, 2] == 'watermark', 3])
colnames(cite_prop) <- c('name', 'title', 'description', 'watermark')
cite_prop[, 'watermark'] <- sub(' [en]', '[en]', cite_prop[, 'watermark'], fixed = TRUE)

# descarregar e processar arquivo `metadatablocks/citation.tsv`
url <-
  'https://raw.githubusercontent.com/GlobalDataverseCommunityConsortium/dataverse/develop/scripts/api/data/metadatablocks/citation.tsv'
cite <- readLines(url)[-(1:2)]
cite[1] <- sub('#datasetField', '', cite[1], fixed = TRUE)
cite <- strsplit(cite[1:(nrow(cite_prop) + 1)], split = '\t')
cite <- do.call(rbind, cite)
colnames(cite) <- cite[1, ]
cite <- cite[-1, ]

# fundir dados
citation <- cbind(cite_prop, cite[, 6:ncol(cite)])

# geospatial ####

# descarregar e processar arquivo geospatial_br.properties
url <-
  'https://raw.githubusercontent.com/GlobalDataverseCommunityConsortium/dataverse-language-packs/develop/pt_BR/geospatial_br.properties'
geo_prop <- readLines(url)[-(1:2)]
geo_prop <- lapply(geo_prop, function (x) {
  strsplit(x, split = '.', fixed = TRUE)[[1]][1:3]
})
geo_prop <- do.call(rbind, geo_prop)
tmp <- lapply(geo_prop[, 3], function (x) {
  strsplit(x, split = '=', fixed = TRUE)[[1]][1:2]
})
tmp <- do.call(rbind, tmp)
geo_prop <- cbind(geo_prop[, 1:2], tmp)
geo_prop <- geo_prop[geo_prop[, 1] == 'datasetfieldtype', -1]
geo_prop <- cbind(
  geo_prop[geo_prop[, 2] == 'title', c(1, 3)],
  geo_prop[geo_prop[, 2] == 'description', 3],
  geo_prop[geo_prop[, 2] == 'watermark', 3])
colnames(geo_prop) <- c('name', 'title', 'description', 'watermark')
geo_prop[, 'watermark'] <- sub(' [en]', '[en]', geo_prop[, 'watermark'], fixed = TRUE)

# descarregar e processar arquivo `metadatablocks/geospatial.tsv`
url <-
  'https://raw.githubusercontent.com/GlobalDataverseCommunityConsortium/dataverse/develop/scripts/api/data/metadatablocks/geospatial.tsv'
geo <- readLines(url)[-(1:2)]
geo[1] <- sub('#datasetField', '', geo[1], fixed = TRUE)
geo <- strsplit(geo[1:(nrow(geo_prop) + 1)], split = '\t')
geo <- do.call(rbind, geo)
colnames(geo) <- geo[1, ]
geo <- geo[-1, ]

# fundir dados
geospatial <- cbind(geo_prop, geo[, 6:ncol(geo)], termURI = NA)

# metadatablock ####
metadatablock <- as.data.frame(rbind(citation, geospatial), stringsAsFactors = FALSE)
metadatablock <- metadatablock[, c(15, 1:2, 14, 3:13, 16)]
colnames(metadatablock) <- sub(' ', '', colnames(metadatablock))

# parent
idx <- match(metadatablock$parent, metadatablock$name)

# title
metadatablock$title <- paste0(metadatablock$title[idx], ": ", metadatablock$title)
metadatablock$title <- sub('NA: ', '', metadatablock$title)

# description
metadatablock$description <- paste0(metadatablock$description[idx], ": ", metadatablock$description, ".")
metadatablock$description <- sub('NA: ', '', metadatablock$description)

# watermark
metadatablock$watermark <- sub('[en]', '', metadatablock$watermark, fixed = TRUE)

# parent
metadatablock <- metadatablock[-na.exclude(idx), ]

# schema
metadatablock <- cbind(schema = 'Dataverse v4.x', metadatablock)

# salvar dados
write.table(x = metadatablock, file = 'def/dataverse.txt', sep = '\t', row.names = FALSE)

wb <- openxlsx::createWorkbook(title = "FEBR Esquema de Metadados v3")
openxlsx::addWorksheet(wb, "identificacao")
openxlsx::writeData(wb = wb, sheet = 1, x = metadatablock[c("schema", "metadatablock_id", "name", "title")])
for (i in seq_along(metadatablock$description)) {
  openxlsx::writeComment(
    wb = wb, sheet = "identificacao", col = 4, row = i + 1, 
    comment = openxlsx::createComment(metadatablock$description[i], visible = FALSE))
}
# openxlsx::openXL(wb)
openxlsx::saveWorkbook(wb = wb, file = "def/identificacao.xlsx", overwrite = TRUE)
