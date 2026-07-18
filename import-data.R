library(quantmod)

# Current price
vwrp_current <- read.csv(
  "https://docs.google.com/spreadsheets/d/e/2PACX-1vRpUNf7QdNgPNEC34segItBiNHNngtTOANTalz6jaECdX9aKRu43QPHM53C9WdhQqiuawk4JcDzho_H/pub?output=csv"
)

# Historic prices
historic_dates <- Sys.Date() - c(1, 7, 30, 90, 180, 365)

getSymbols(Symbols = "VWRP.L", auto_assign = TRUE, from = min(historic_dates))
vwrp_df <- data.frame(date = index(VWRP.L), coredata(VWRP.L))[c(
  "date",
  "VWRP.L.Close"
)]

date_select <- vapply(
  historic_dates,
  function(x) {
    which.min(abs(x - vwrp_df$date))
  },
  integer(1)
)

vwrp_df2 <- vwrp_df[date_select, ]

# Combine current and selected historic prices
vwrp_df2 <- rbind(
  data.frame(
    date = as.Date(vwrp_current$date, "%d/%m/%Y"),
    VWRP.L.Close = vwrp_current$price
  ),
  vwrp_df2
)

# Change in price
vwrp_df2$change <- vwrp_df2$VWRP.L.Close[1] - vwrp_df2$VWRP.L.Close
vwrp_df2$changep <- vwrp_df2$VWRP.L.Close[1] / vwrp_df2$VWRP.L.Close - 1

# Change from peak price
max_price <- max(vwrp_df$VWRP.L.Close, na.rm = TRUE)
vwrp_df2$change_peak <- (max_price - vwrp_df2$VWRP.L.Close) / max_price

# Formatting
vwrp_df2$date <- format(vwrp_df2$date, "%d %b %Y")

vwrp_df2$VWRP.L.Close <- formatC(
  vwrp_df2$VWRP.L.Close,
  digits = 2,
  format = "f"
)
vwrp_df2$VWRP.L.Close <- paste0("£", vwrp_df2$VWRP.L.Close)

vwrp_df2$change <- formatC(vwrp_df2$change, digits = 2, format = "f")
vwrp_df2$change <- paste0("£", vwrp_df2$change)

vwrp_df2$changep <- formatC(vwrp_df2$changep * 100, digits = 1, format = "f")
vwrp_df2$changep <- paste0(vwrp_df2$changep, "%")

vwrp_df2$change_peak <- formatC(
  vwrp_df2$change_peak * 100,
  digits = 1,
  format = "f"
)
vwrp_df2$change_peak <- paste0(vwrp_df2$change_peak, "%")


# Export
names(vwrp_df2) <- c(
  "Date",
  "Price",
  "Change",
  "Percent Change",
  "Change from Peak"
)
write.csv(vwrp_df2, "out.csv", na = "", row.names = FALSE)
