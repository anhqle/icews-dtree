# Get ICEWS event data for gdelt-to-mids project
# MCD, adapted from script by AB
# February 2014
#
# dbGetEvents() function to pull events for a country over date range for 
#   given CAMEO codes from ICEWS database.
#   Output df: source, country, date, latitude, longitude, cameo_code

dbSetup <- function() {
  db.user <- "mattd"
  db.pw <- "chair8345"
  if (db.pw=="") stop("Fill in database password")
  
  # Try MySQL
  library(RMySQL)
  tryCatch(conn <<- dbConnect(MySQL(), user=db.user, password=db.pw, 
                              dbname="event_data", host="152.3.32.10"), 
           error=function(e) warning("MySQL connection does not work"))
}

dbGetEvents <- function(source_country, target_country, start.date, end.date) {
  data.source = "icews"
  if (!data.source %in% c("icews")) stop("data.source must be 'icews'")
  if (as.Date(start.date) >= as.Date(end.date)) stop("start date must be before end date")
  
  # Query for ICEWS as data source
  if (data.source=="icews") {
    # Get country ID
    # In future add something to check whether country is in CountryName
    sql <- paste0(
      "SELECT id AS source_id FROM countries WHERE COWAbb='",
      toupper(source_country), 
      "';")
    source_id <- dbGetQuery(conn, sql)

    sql <- paste0(
      "SELECT id AS source_id FROM countries WHERE COWAbb='",
      toupper(target_country), 
      "';")
    target_id <- dbGetQuery(conn, sql)
    
    # Get ICEWS event codes
    # sql <- paste0(
    #   "SELECT eventtype_ID FROM eventtypes \n",
    #   "WHERE code IN ", formatList(cameo.codes), ";"
    # )
    # icews.codes <- dbGetQuery(conn, sql)$eventtype_ID
    sql <- paste0(
      "SELECT eventtype_ID FROM eventtypes;"
    )
    icews.codes <- dbGetQuery(conn, sql)$eventtype_ID
    
    dbSendQuery(conn, "DROP TABLE IF EXISTS my_tables.matt_results;")
    # Subset events by date and country
    sql <- paste0(
      "CREATE TABLE my_tables.matt_results AS \n",
      "SELECT 'icews' AS source, '", source_country, "' AS source_country, \n",
      "   '", target_country, "'AS target_country, \n",
      "    event_date AS date, eventtype_ID, location_ID \n",
      "FROM events \n",
      # "WHERE source_actor_id=", source_id, " \n",
      # "AND target_actor_id=", target_id, " \n",
      "WHERE event_Id IN (SELECT event_id FROM event_source_country_mappings WHERE country_id=", source_id, ")\n",
      "AND event_Id IN (SELECT event_id FROM event_target_country_mappings WHERE country_id=", target_id, ")\n",
      "AND event_date BETWEEN '", start.date, "' AND '", end.date, "'\n",
      # "AND eventtype_ID IN ", formatList(icews.codes), "\n",
      ";")
    # print(sql)
    dbSendQuery(conn, sql)
    # Add cameo codes
    dbSendQuery(conn, "ALTER TABLE my_tables.matt_results ADD COLUMN cameo_code varchar(6);")
    dbSendQuery(conn, paste0(
      "UPDATE my_tables.matt_results JOIN eventtypes \n",
      "SET my_tables.matt_results.cameo_code = eventtypes.code \n",
      "WHERE (my_tables.matt_results.eventtype_ID = eventtypes.eventtype_ID);"))
    # Add latitude
    dbSendQuery(conn, "ALTER TABLE my_tables.matt_results ADD COLUMN latitude float;")
    dbSendQuery(conn, paste0(
      "UPDATE my_tables.matt_results JOIN locations \n",
      "SET my_tables.matt_results.latitude = locations.Latitude \n",
      "WHERE (my_tables.matt_results.location_ID = locations.location_ID);"))
    # Add longitude
    dbSendQuery(conn, "ALTER TABLE my_tables.matt_results ADD COLUMN longitude float;")
    dbSendQuery(conn, paste0(
      "UPDATE my_tables.matt_results JOIN locations \n",
      "SET my_tables.matt_results.longitude = locations.Longitude \n",
      "WHERE (my_tables.matt_results.location_ID = locations.location_ID);"))
    # Drop eventtype and location keys
    dbSendQuery(conn, "ALTER TABLE my_tables.matt_results 
                DROP COLUMN eventtype_ID,
                DROP COLUMN location_ID;")
    res <- dbGetQuery(conn, "SELECT * FROM my_tables.matt_results;")
    # dbSendQuery(conn, "DROP TABLE my_tables.matt_results;")
  }
  return(res)
}

# Test it
# dbSetup()
# t1 <- dbGetEvents("USA", "PER", "1992-01-01", "1995-01-01")

# t1
