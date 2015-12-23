require(RMySQL)
require(utils)

setwd("~/git/fts_article/")

# Pretty basic check, but useful.
if(!file.exists('pg1232.txt')) download.file('http://www.gutenberg.org/cache/epub/1232/pg1232.txt', 'pg1232.txt')

# Horrible, but due to an issue when working with debugging in RStudio, some
# connections halt
all_cons <- dbListConnections(MySQL())
for(con in all_cons) dbDisconnect(con)

# You do not want clear passwords, but is a sandbox.
con <- dbConnect(MySQL(), 
                 user="msandbox", password="msandbox", port=14901 
                 ,dbname="test", socket="/tmp/mysql_sandbox14901.sock", 
                 host="127.0.0.1")
# on.exit(dbDisconnect(con))

## check all connections have been closed
# dbListConnections(MySQL())

loadfile <- 'output.txt'
loadfileline <- 'outputLine.txt'

fileConn<-file(loadfile)
fileConnByLine<-file(loadfileline)


# Raw content of the book by paragraph splitting 
rawContent <- paste(readLines("pg1232.txt"), collapse = "\n")
rawContent <- unlist(strsplit(rawContent, "\n[ \t\n]*\n"))

# Raw content by line splitting
rawContentByLine <- readLines("pg1232.txt")
rawContentByLine <- unlist(strsplit(rawContentByLine, "\n[ \t\n]*\n"))


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


# This is not the best way to do so. Instead, you want to load into file. IDIOT.
insertParagraph <- function (bookid, content) {
  sql <- sprintf("insert into books_content
               (book_id, paragraph)
               values (%d, '%s');",
                 bookid, content)
  rs <- dbSendQuery(con, sql)

}

# bookid = 1 (no other books on this test at the moment)
tableContent <- data.frame(gsub("\\n", "", rawContent), stringAsFactors=FALSE)
tableContent <- cbind(1, tableContent )

tableContentByLine <- data.frame(gsub("\\n", "", rawContentByLine), stringAsFactors=FALSE)
tableContentByLine <- cbind(1, tableContentByLine )


colnames(tableContent) <- c("bookid","content")
tableContent <- tableContent[complete.cases(tableContent),]

colnames(tableContentByLine) <- c("bookid","content")
# No need this as it has been clean before: tableContent <- tableContent[complete.cases(tableContent),]


write.table(tableContent, file = loadfile, col.names = FALSE, 
            append = FALSE, quote = TRUE, qmethod = c("escape"),
            sep = "|", row.names = FALSE)


write.table(tableContentByLine, file = loadfileline, col.names = FALSE, 
            append = FALSE, quote = TRUE, qmethod = c("escape"),
            sep = "|", row.names = FALSE)


sql <- paste("LOAD  DATA LOCAL INFILE \'",as.character(loadfile),"\'
        INTO TABLE test.bookContent FIELDS TERMINATED BY \'|\' (bookid,content); ", sep = "")
rs <- dbGetQuery(con,sql)

sql <- paste("LOAD  DATA LOCAL INFILE \'", as.character(loadfileline),"\' 
        INTO TABLE test.bookContentByLine FIELDS TERMINATED BY \'|\' (bookid,content); ", sep = "" )
rs <- dbGetQuery(con,sql)


dbGetQuery(con, "CREATE FULLTEXT INDEX ftscontent ON bookContent(content);")
dbGetQuery(con, "CREATE FULLTEXT INDEX ftscontent ON bookContentByLine(content);")

### Turning down the music
dbDisconnect(con)
close(fileConn)





