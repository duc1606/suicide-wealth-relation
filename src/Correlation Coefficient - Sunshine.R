#setup: run: install.packages('reticulate')
library('tidyverse')
library('RColorBrewer')
suicide_rate <- read.csv('csv_files/master.csv')
sunshine <- read.csv('csv_files/Sunshine_hours.csv')
geographic_coordinates <- read.csv('csv_files/longitude & latitude every country.csv')
#sunshine source: https://data.world/makeovermonday/2019w44



#columns were labeled incorrectly
suicide_rate <- rename(suicide_rate, gdp_for_year = gdp_for_year...., gdp_per_capita = gdp_per_capita....,  suicides_100k_pop = suicides.100k.pop)


#tidy master.csv
suicide_rate_tidy <- select(suicide_rate, country, year, suicides_no, population, suicides_100k_pop, gdp_for_year, gdp_per_capita)
suicide_rate_tidy <- group_by(suicide_rate_tidy, country, year, gdp_for_year, gdp_per_capita)
suicide_rate_tidy <- summarise(suicide_rate_tidy, suicides_no = sum(suicides_no), population = sum(population), suicides_100k_pop = (sum(suicides_no)/sum(population)) * 100000)

#number of years represented in master.csv
number_of_occurrences <- group_by(suicide_rate_tidy, country)
number_of_occurrences <- summarise(number_of_occurrences, Number_of_Years = n_distinct(year))

#merge to delete out every country with less than 20 years of data
suicide_rate_tidy <- merge(suicide_rate_tidy, number_of_occurrences)
suicide_rate_tidy <- filter(suicide_rate_tidy, Number_of_Years > 19)


#getting mean for the first general visualization of gdp to suicide_number_100k
all_countries_mean <- group_by(suicide_rate_tidy, country)
all_countries_mean <- summarise(all_countries_mean, gdp_per_capita_avg = mean(gdp_per_capita), suicides_no_avg = mean(suicides_no), suicdes_no_sum = sum(suicides_no), suicide_100k_pop_avg = mean(suicides_100k_pop))


#tidy Sunshine_hours.csv
sunshine_tidy <- group_by(sunshine, Country)
sunshine_tidy$sunshine_avg <- rowSums(sunshine[, c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")], na.rm = TRUE)
sunshine_tidy <- rename(sunshine_tidy, country = Country)
sunshine_tidy <- select(sunshine_tidy, country, sunshine_avg)
sunshine_tidy <- summarise(sunshine_tidy, sunshine_avg = mean(sunshine_avg))


#calculate correlation coefficient
correlation_coef <- group_by(suicide_rate_tidy, country)
correlation_coef <- summarise(correlation_coef, correlation = cor(gdp_per_capita, suicides_100k_pop, use = 'complete.obs'), suicides_100k_pop)
correlation_coef <- summarise(correlation_coef, correlation = mean(correlation))

#tidy geographic_coordinates
geographic_coordinates <- group_by(geographic_coordinates, country)
geographic_coordinates <- select(geographic_coordinates, country, latitude, longitude)


#merge the datasets together
suicide_rate_to_sunshine <- merge(sunshine_tidy, all_countries_mean, by = "country")
suicide_rate_to_coordinates <- merge(geographic_coordinates, correlation_coef, by = "country")
suicide_rate_to_sunshine <- merge(suicide_rate_to_sunshine, correlation_coef, by = "country")
scatterplot_latitude_sunshine_suiciderate <- merge(geographic_coordinates, all_countries_mean, by = "country")
scatterplot_latitude_sunshine_suiciderate <- merge(scatterplot_latitude_sunshine_suiciderate, sunshine_tidy, by = "country")



# plot the correlation coefficients to sunshine
ggplot(data = suicide_rate_to_sunshine) +
  aes(x = reorder(country, correlation), y = sunshine_avg, fill = correlation) +
  geom_bar(stat = "identity") +
  scale_fill_distiller(palette = "YlOrRd", direction = 1) +
  labs(x = "Countries", y = "Sunshine", title = "Correlation Coefficient to Sunshine") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, size = 6))


# plot the correlation coefficients to coordinates
ggplot(data = suicide_rate_to_coordinates) +
  aes(x = reorder(country, correlation), y = latitude, fill = correlation) +
  geom_bar(stat = "identity") +
  scale_fill_distiller(palette = "YlOrRd", direction = 1) +
  labs(x = "Countries", y = "latitude", title = "Correlation Coefficient to latitude") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, size = 6))


# scatter plot latitude to suicide rate
ggplot(data = scatterplot_latitude_sunshine_suiciderate) +
  aes(x = suicide_100k_pop_avg, y = latitude, color = country) +
  geom_point(size = 3) +
  scale_x_log10() +
  geom_text(aes(label = country), vjust = -0.5, hjust = 0.5, size = 3) +
  labs(title = "Latitude to suicides per 100k Population",
       x = "suicides per 100k Population Average",
       y = "latitude") +
  theme(legend.position = "none")

# scatter plot sunshine index to suicide rate
ggplot(data = scatterplot_latitude_sunshine_suiciderate) +
  aes(x = suicide_100k_pop_avg, y = sunshine_avg, color = country) +
  geom_point(size = 3) +
  scale_x_log10() +
  geom_text(aes(label = country), vjust = -0.5, hjust = 0.5, size = 3) +
  labs(title = "Sunshine Index to suicides per 100k Population",
       x = "suicides per 100k Population Average",
       y = "Sunshine Average") +
  theme(legend.position = "none")
