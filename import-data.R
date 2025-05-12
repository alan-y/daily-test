library(quantmod)

# Current price
vwrp_current <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vRpUNf7QdNgPNEC34segItBiNHNngtTOANTalz6jaECdX9aKRu43QPHM53C9WdhQqiuawk4JcDzho_H/pub?output=csv")

# Historic prices
lastd <- Sys.Date() - 1
lastw <- Sys.Date() - 7
lastm <- Sys.Date() - 30
last3m <- Sys.Date() - 90
last6m <- Sys.Date() - 180
lasty <- Sys.Date() - 365

getSymbols(Symbols = "VWRP.L", auto_assign = TRUE, from = lasty)
vwrp_df <- data.frame(date = index(VWRP.L), coredata(VWRP.L))[c("date", "VWRP.L.Close")]

date_select <- c(
  which.min(abs(lastd - vwrp_df$date)),
  which.min(abs(lastw - vwrp_df$date)),
  which.min(abs(lastm - vwrp_df$date)),
  which.min(abs(last3m - vwrp_df$date)),
  which.min(abs(last6m - vwrp_df$date)),
  which.min(abs(lasty - vwrp_df$date))
)

vwrp_df2 <- vwrp_df[date_select, ]

# Combine current and selected historic prices
vwrp_df2 <- rbind(
  data.frame(date = as.Date(vwrp_current$date, "%d/%m/%Y"),
             VWRP.L.Close = vwrp_current$price),
  vwrp_df2
)

# Change in price
vwrp_df2$change <- vwrp_df2$VWRP.L.Close[1] - vwrp_df2$VWRP.L.Close
vwrp_df2$change <- round(vwrp_df2$change, 2)
vwrp_df2$changep <- vwrp_df2$VWRP.L.Close[1]/vwrp_df2$VWRP.L.Close - 1
vwrp_df2$changep <- round(vwrp_df2$changep * 100, 1)
vwrp_df2$VWRP.L.Close <- round(vwrp_df2$VWRP.L.Close, 2)

# Export
names(vwrp_df2) <- c("Date", "Price", "Change", "Percent Change")
write.csv(vwrp_df2, "out.csv", na = "", row.names = FALSE)
