
# basic set-if-unset operator
"%||=%" <- function(x, y){
   Var <- deparse(substitute(x))
   if (!exists(Var))
     assign(Var, y, parent.frame())
}

# set variables if not set yet
serveraddr %||=% "127.0.0.1"
user       %||=% "default"
password   %||=% ""
tblname    %||=% "test"

getRealConnection <- function(){
  # TODO: recycle connection by using singleton?
  conn <- dbConnect(RClickhouse::clickhouse(), host=serveraddr, user=user, password=password)
  return (conn)
}

#' @export
#' @rdname tbl_lazy
simulate_clickhouse <- function(type = NULL) {
  structure(
    list(),
    class = c(type, "ClickhouseConnection", "DBITestConnection", "DBIConnection")
  )
}

writeReadTest <- function(input, result = input, types = NULL) {
  skip_on_cran()
  conn <- getRealConnection()

  dbWriteTable(conn, tblname, input, overwrite=T, field.types=types)
  r <- dbReadTable(conn, tblname)
  expect_equal(r, result)
  dbDisconnect(conn)
}
