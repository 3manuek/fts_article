require(RMySQL)
require(utils)

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

fileConn<-file("output.txt")

setwd("~/git/fts_article/")

rawContent <- paste(readLines("pg1232.txt"), collapse = "\n")
rawContent <- unlist(strsplit(rawContent, "\n[ \t\n]*\n"))

# Limitation. Using FTS_DOC_ID 
dbGetQuery(con, "CREATE TABLE IF NOT EXISTS bookContent
                 (
                 FTS_DOC_ID BIGINT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY, 
                 bookid bigint, content text);
")


# This is not the best way to do so. Instead, you want to load into file. IDIOT.
inserParagraph <- function (bookid, content) {
  sql <- sprintf("insert into books_content
               (book_id, paragraph)
               values (%d, '%s');",
                 bookid, content)
  rs <- dbSendQuery(con, sql)

}

tableContent <- data.frame(gsub("\\n", "", rawContent), stringAsFactors=FALSE)
tableContent <- cbind(1, tableContent )
#tableContent <- cbind( seq(1,length(rawContent)), tableContent  )

colnames(tableContent) <- c("bookid","content")
tableContent <- tableContent[complete.cases(tableContent),]

write.table(tableContent, file = "output.txt", col.names = FALSE, 
            append = FALSE, quote = TRUE, qmethod = c("escape"),
            sep = "|", row.names = FALSE)

sql <- "LOAD  DATA LOCAL INFILE \'output.txt\' 
        INTO TABLE test.bookContent 
        FIELDS TERMINATED BY \'|\' (bookid,content); "
rs <- dbGetQuery(con,sql)


dbGetQuery(con, "CREATE FULLTEXT INDEX ftscontent ON bookContent(content);
")

dbDisconnect(con)
close(fileConn)





