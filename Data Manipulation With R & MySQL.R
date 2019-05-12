# install.packages(c("readr", "tidyr", "dplyr", "RMySQL"))

library(RMySQL)
library(readr)
library(tidyr)
library(dplyr)

srv <- "localhost" # ganti dengan IP yang akan diberikan oleh pembicara
port <- 3306
dbn <- "nycflights"
usr <- "user1"
pwd <- "P@ssw0rd"

mycon <- dbConnect(MySQL(), 
                   host = srv, 
                   dbname = dbn, 
                   user = usr, 
                   password = pwd, 
                   port = port)
dbListTables(mycon)
flights <- as_tibble(dbReadTable(mycon, "flights"))
airlines <- as_tibble(dbReadTable(mycon, "airlines"))
airports <- as_tibble(dbReadTable(mycon, "airports"))
weather <- as_tibble(dbReadTable(mycon, "weather"))
planes <- as_tibble(dbReadTable(mycon, "planes"))

dbDisconnect(mycon)

download.file(url = "https://raw.githubusercontent.com/aephidayatuloh/dm_dplyr/master/prices.csv", 
              destfile = "D:/pelatihanR/prices.csv")
download.file(url = "https://raw.githubusercontent.com/aephidayatuloh/dm_dplyr/master/specialdays.csv", 
              destfile = "D:/pelatihanR/specialdays.csv")

# Import data dari CSV tersebut ke R
prices <- read_delim("D:/pelatihanR/prices.csv", delim = ";")
specialdays <- read_csv("D:/pelatihanR/specialdays.csv")

prices <- read_delim("https://raw.githubusercontent.com/aephidayatuloh/dm_dplyr/master/prices.csv", delim = ";")

specialdays <- read_csv("https://raw.githubusercontent.com/aephidayatuloh/dm_dplyr/master/specialdays.csv")


dim(flights)
glimpse(flights)
head(flights)
summary(flights)

distinct(flights, year)
distinct(flights, origin)
distinct(flights, dest)

distinct(flights, dest, .keep_all = TRUE)
distinct(flights)

select(flights, month, day, dep_time, dep_delay, arr_time, arr_delay, origin, dest)
select(flights, c(2:4, 6:7, 9, 13:14))

select(flights, -year)
select(flights, -1)

# memilih baris ke-1 s/d 1000
slice(flights, 1:1000)

filter(flights, dep_delay >= 10)
filter(flights, dep_delay >= 10 & origin == "JFK")
filter(flights, month == 1 & day == 1 & origin == "JFK" & dest == "ATL")
filter(flights, is.na(dep_time))

# Urutkan data frame flights berdasarkan variabel `origin`
arrange(flights, origin)

# Urutkan data frame flights berdasarkan variabel `origin` dan `dest`
arrange(flights, origin, dest)

# Urutkan data frame flights berdasarkan variabel `origin` secara ascending dan `dest` secara descending
arrange(flights, origin, desc(dest))

# Banyaknya NA
sum(is.na(flights["air_time"]))

flights_na999 <- flights
# Merubah NA dengan -999
flights_na999$air_time <- if_else(is.na(flights$air_time), -999, flights$air_time)

# Banyaknya NA
sum(is.na(flights_na999["air_time"]))

# Banyaknya NA yang sudah diganti -999
sum(flights_na999["air_time"] == -999)

# Ganti nilai NA menjadi -999
flights_na999$air_time <- na_if(flights_na999$air_time, -999)

# Banyaknya -999
filter(flights_na999, air_time == -999)

# Banyaknya NA
sum(is.na(flights_na999$air_time))

# Membuang semua baris yang mengandung NA
flights_NoNA <- drop_na(flights)

# Mengganti NA pada masing-masing kolom dengan nilai tertentu
replace_na(flights, list(dep_time = 0, dep_delay = 0, arr_time = mean(flights$arr_time, na.rm = TRUE), arr_delay = median(flights$arr_delay, na.rm = TRUE)))

selected <- select(flights, dep_delay, arr_time, arr_delay, origin, dest, air_time)
filtered <- filter(selected, dep_delay >= 10 & origin == "JFK")
hasil <- arrange(filtered, origin)
hasil

hasil <- arrange(filter(select(flights, dep_delay, arr_time, arr_delay, origin, dest, air_time), dep_delay >= 10 & origin == "JFK"), origin)
hasil

flights %>% 
  select(dep_delay, arr_time, arr_delay, origin, dest, time_hour) %>% 
  filter(origin == "JFK" & between(dep_delay, -10, 100)) %>% 
  arrange(origin, desc(dest)) 

flights %>% 
  select(dep_delay, arr_time, arr_delay, origin, dest, time_hour) %>% 
  filter(origin == "JFK" & between(dep_delay, -10, 100)) %>% 
  arrange(origin, desc(dest)) %>% 
  mutate(is_delay = if_else(dep_delay > 0, 1, 0),
         time_hour = as.POSIXct(time_hour))

flights %>%
  count()

flights %>% 
  count(origin, dest)

flights %>% 
  mutate(is_delay = dep_delay > 0) %>% 
  count(origin, is_delay) %>%
  spread(key = origin, value = n)

flights %>% 
  drop_na() %>% 
  summarise(rata2_delay = mean(dep_delay))

flights %>% 
  group_by(origin, dest, month) %>% 
  summarise(rata2_delay = mean(dep_delay, na.rm = TRUE)) %>% 
  arrange(rata2_delay) 

flights %>% 
  group_by(origin, dest) %>% 
  summarise(rata2_delay = mean(dep_delay, na.rm = TRUE))

flights %>% 
  group_by(origin, dest) %>% 
  summarise(rata2_delay = mean(dep_delay, na.rm = TRUE)) %>% 
  spread(key = origin, value = rata2_delay) # soon replaced with pivot_wider()

flights %>% 
  group_by(origin, dest) %>% 
  summarise(rata2_delay = mean(dep_delay, na.rm = TRUE)) %>% 
  spread(key = origin, value = rata2_delay) %>% # soon replaced with pivot_wider()
  gather(key = origin, value = rata2_delay, -dest) # soon replaced with pivot_longer()

tb <- flights %>%
  group_by(month) %>% 
  count()

plot(tb$month, tb$n, "l")


tb <- flights %>%
  group_by(day) %>% 
  count()

plot(tb$day, tb$n, "l")


tb <- flights %>%
  mutate(dates = as.Date(paste(year, month, day, sep = "-"), format = "%Y-%m-%d")) %>%
  group_by(dates) %>% 
  count()
plot(tb$dates, tb$n, "l")

paste("nilai ini", 9)
paste("nilai ini", 9, sep = "-")


tbl1 <- flights %>%
  inner_join(weather, by = c("year", "month", "day", "hour", "origin", "time_hour"))
glimpse(tbl1)
head(tbl1)

tbl2 <- flights %>%
  left_join(airports, by = c("origin" = "faa")) %>%
  left_join(airports, by = c("dest" = "faa"), suffix = c("_origin", "_dest"))
glimpse(tbl2)
head(tbl2)

