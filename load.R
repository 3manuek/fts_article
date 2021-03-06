#!/usr/bin/Rscript
require(RMySQL)
require(utils)
library(stringr)
library(optparse) # https://github.com/trevorld/optparse
                  # devtools::install_github("trevorld/optparse")

#randnums <- 5
set.seed(1)

setwd("~/git/fts_article/")

#parsing arguments for future purposes
parser <- OptionParser()
#parser <- add_option(parser, c("-v", "--verbose"), action="store_true",
#                                        default=TRUE, help="Print extra output [default]")
#parser <- add_option(parser, c("-q", "--quietly"), action="store_false",
#                                            dest="verbose", help="Print little output")
parser <- add_option(parser, c("-b", "--books"), type="integer", default=5,
                                        help="Number of books to download [default %default]")
                                        #metavar="randnums")
#parse_args(parser, args = c("--quietly", "--count=15"))
opts <- parse_args(parser)

numbooks <- opts$books

# Probably adding more stuff here

# Horrible, but due to an issue when working with debugging in RStudio, some
# connections halt
all_cons <- dbListConnections(MySQL())
for(con in all_cons) dbDisconnect(con)

# You do not want clear passwords, but is a sandbox.
con <- dbConnect(MySQL(), 
                 user="msandbox", password="msandbox", port=13454 
                 ,dbname="test", socket="/tmp/mysql_sandbox13454.sock", 
                 host="127.0.0.1")
# on.exit(dbDisconnect(con))


# Just cleaning for test
dbGetQuery(con,"DROP TABLE IF EXISTS bookContent;")
dbGetQuery(con,"DROP TABLE IF EXISTS bookContentByLine;")
# Limitation. Using FTS_DOC_ID 
dbGetQuery(con, "CREATE TABLE IF NOT EXISTS bookContent
                 (
                   FTS_DOC_ID BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
                   bookid bigint, 
                   content text
                 ); ")

dbGetQuery(con, "CREATE TABLE IF NOT EXISTS bookContentByLine
                 (
                   FTS_DOC_ID BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
                   bookid bigint, 
                   content text
                 ); ")

# Other way to create the table within other PK:
# node1 [localhost] {msandbox} (test) > CREATE TABLE test (  FTS_DOC_ID bigint unsigned  AUTO_INCREMENT, kk bigint, other text, PRIMARY KEY(kk),UNIQUE(FTS_DOC_ID));
# Query OK, 0 rows affected (0,08 sec)



#vector of ids for book downloading
#randids <- abs(round(rnorm(opts$books)*1000))

# How many downloaded books?

#rest <- randnums - length(dir(pattern = "pg.*txt"))

#for (bi in 1:opts$books) {
#  tempFileName <- paste('http://www.gutenberg.org/cache/epub/' 
#                        ,randids[bi], 
#                        '/pg',randids[bi],'.txt', sep = ""
#                        )
#  if(file.exists(tempFileName)) {next} 
#  download.file(tempFileName, paste('pg',randids[bi],'.txt', sep = ""))
#}

rest <- numbooks - length(dir(path = "./books",pattern = "pg.*txt"))

#for (bi in 1:opts$randnums) {
#  tempFileName <- paste('http://www.gutenberg.org/cache/epub/' 
#                        ,randids[bi], 
#                        '/pg',randids[bi],'.txt', sep = ""
#                        )
#  if(file.exists(tempFileName)) {next} 
#  download.file(tempfileName, paste('pg',randids[bi],'.txt'), sep = "")
#}



# Pretty basic check, but useful.
#if(!file.exists(paste('pg', randids ,'.txt'))) download.file('http://www.gutenberg.org/cache/epub/1232/pg1232.txt', 'pg1232.txt')

## check all connections have been closed
# dbListConnections(MySQL())

#loadfile <- 'output'
#loadfileline <- 'outputLine'

#loadFiles <- paste('ouput' ,rids, sep = "")
#loadFilesLine <- paste('ouputLine' , rids, sep = "")

#fileConn<-file(loadfile)
#fileConnByLine<-file(loadfileline)

listOfDownloadedFiles <- sort(dir(path = "./books", 
                                  full.names = TRUE, pattern = "pg.*txt$"))

for (fi in listOfDownloadedFiles) {
  
  downloadFile <- paste(fi, ".load",sep = "")
  downloadFileLine <- paste(fi, ".line.load",sep = "")
  idBook <- as.numeric(str_extract(fi,"[0-9]+"))
  #fipath <- paste("./books/",fi,sep = "")

  fileConn<-file(downloadFile)
  fileConnByLine<-file(downloadFileLine)
    
  # Raw content of the book by paragraph splitting 
  rawContent <- paste(readLines(fi), collapse = "\n")
  rawContent <- unlist(strsplit(rawContent, "\n[ \t\n]*\n"))
  
  # Raw content by line splitting
  rawContentByLine <- readLines(fi)
  rawContentByLine <- unlist(strsplit(rawContentByLine, "\n[ \t\n]*\n"))
  
  # bookid = 1 (no other books on this test at the moment)
  tableContent <- data.frame(gsub("\\n", "", rawContent), stringAsFactors=FALSE)
  tableContent <- cbind(idBook, tableContent )
  
  tableContentByLine <- data.frame(gsub("\\n", "", rawContentByLine), stringAsFactors=FALSE)
  tableContentByLine <- cbind(idBook, tableContentByLine )

  colnames(tableContent) <- c("bookid","content")
  tableContent <- tableContent[complete.cases(tableContent),]
  
  colnames(tableContentByLine) <- c("bookid","content")
  # No need this as it has been clean before: tableContent <- tableContent[complete.cases(tableContent),]
  
  
  write.table(tableContent, file = downloadFile, col.names = FALSE, 
              append = FALSE, quote = TRUE, qmethod = c("escape"),
              sep = "|", row.names = FALSE)
  
  
  write.table(tableContentByLine, file = downloadFileLine, col.names = FALSE, 
              append = FALSE, quote = TRUE, qmethod = c("escape"),
              sep = "|", row.names = FALSE)
  close(fileConn)
  close(fileConnByLine)
}

loadFiles <- function(loadFileName) {
  sql <- paste("LOAD  DATA LOCAL INFILE \'",as.character(loadFileName),"\'
        INTO TABLE test.bookContent FIELDS TERMINATED BY \'|\' (bookid,content); ", sep = "")
  rs <- dbGetQuery(con,sql)
  
}

loadFilesLine <- function(loadFileName){
  sql <- paste("LOAD  DATA LOCAL INFILE \'", as.character(loadFileName),"\' 
        INTO TABLE test.bookContentByLine FIELDS TERMINATED BY \'|\' (bookid,content); ", sep = "" )
  rs <- dbGetQuery(con,sql)
  
}

listOfLoadFiles <- sort(dir(path = "./books",full.names = TRUE,pattern = "pg.*txt.load$"))
listOfLoadFilesLine <- sort(dir(path = "./books",full.names = TRUE,pattern = "pg.*txt.line.load$"))

sapply(listOfLoadFiles, loadFiles)
sapply(listOfLoadFilesLine, loadFilesLine)

# This is not the best way to do so. Instead, you want to load into file. IDIOT.
#insertParagraph <- function (bookid, content) {
#  sql <- sprintf("insert into books_content
#               (book_id, paragraph)
#               values (%d, '%s');",
#                 bookid, content)
#  rs <- dbSendQuery(con, sql)
#}


dbGetQuery(con, "CREATE FULLTEXT INDEX ftscontent ON bookContent(content);")
dbGetQuery(con, "CREATE FULLTEXT INDEX ftscontent ON bookContentByLine(content);")
dbGetQuery(con, "CREATE INDEX ftsbookid ON bookContent(bookid);")
dbGetQuery(con, "CREATE INDEX ftsbookid ON bookContentByLine(bookid);")

### Turning down the music
dbDisconnect(con)
#close(fileConn)





