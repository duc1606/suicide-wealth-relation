# Load necessary libraries
library(dplyr)
library(ggplot2)
library(readr)

# Read the file
filename <- "src/csv_files/master.csv"
df <- read_csv(filename)

# Adjust column names to be consistent and user-friendly
colnames(df) <- gsub("suicides/100k pop", "suicides_pop", colnames(df))
colnames(df) <- gsub("HDI for year", "HDI_for_year", colnames(df))
colnames(df) <- gsub(" gdp_for_year \\(\\$\\) ", "gdp_for_year", colnames(df))
colnames(df) <- gsub(" gdp_per_capita \\(\\$\\)", "gdp_per_capita", colnames(df))
colnames(df) <- gsub("gdp_per_capita \\(\\$\\)", "gdp_per_capita", colnames(df))

# Adjust country names for consistency
df <- df %>%
  mutate(country = recode(country, 
                          "Republic of Korea" = "Korea, Republic of",
                          "Czech Republic" = "Czechia",
                          "Macau" = "Macao",
                          "Saint Vincent and Grenadines" = "Saint Vincent and the Grenadines"))

# Filter countries with data for at least 20 years
df <- df %>%
  group_by(country) %>%
  filter(n_distinct(year) >= 20) %>%
  ungroup()

# Summarize suicide numbers and population by country and year
df_suino <- df %>% group_by(country, year) %>% summarise(suicides_no = sum(suicides_no))
df_pop <- df %>% group_by(country, year) %>% summarise(population = sum(population))

# Calculate ratios
df_total <- df_suino %>%
  left_join(df_pop, by = c("country", "year")) %>%
  mutate(suicide_ratio = (suicides_no / population) * 100) %>%
  arrange(country, year)

# Calculate average suicide rates per country
country_dict <- df_total %>%
  group_by(country) %>%
  summarise(mean_suicide_ratio = mean(suicide_ratio, na.rm = TRUE)) %>%
  arrange(desc(mean_suicide_ratio))

# Extract top 10 countries with highest average suicide rates
country_list <- country_dict$country
country_suicide <- country_dict$mean_suicide_ratio
top_10_countries <- head(country_list, 10)

# Filter data for the top 10 countries
df_top_10 <- df_total %>% filter(country %in% top_10_countries)

# Plot the temporal development of suicide rates for the top 10 countries
ggplot(df_top_10, aes(x = year, y = suicide_ratio, color = country)) +
  geom_line() +
  geom_point() +
  xlab("Year") +
  ylab("Ratio of Suicide") +
  ggtitle("Suicide Rate Over Time for Top 10 Countries") +
  theme_minimal()

# Calculate average GDP per capita per country and year
df_gdp <- df %>%
  group_by(country, year) %>%
  summarise(gdp_per_capita = mean(gdp_per_capita, na.rm = TRUE)) %>%
  arrange(country, year)

# Filter data for the top 10 countries
df_gdp_top_10 <- df_gdp %>% filter(country %in% top_10_countries)

# Plot the temporal development of GDP per capita for the top 10 countries
ggplot(df_gdp_top_10, aes(x = year, y = gdp_per_capita, color = country)) +
  geom_line() +
  geom_point() +
  xlab("Year") +
  ylab("GDP per Capita") +
  ggtitle("GDP per Capita Over Time for Top 10 Countries") +
  theme_minimal()

# Combine GDP per capita and suicide rates for the top 10 countries
df_gdp_total <- df_gdp %>%
  inner_join(df_total, by = c("country", "year"))

df_gdp_total_top_10 <- df_gdp_total %>%
  filter(country %in% top_10_countries)

# Create scatterplot with regression lines to visualize the relationship between GDP per capita and suicide rates
ggplot(df_gdp_total_top_10, aes(x = gdp_per_capita, y = suicide_ratio, color = country)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  scale_y_continuous(limits = c(0, 0.06)) +
  xlim(0, NA) +
  labs(x = "GDP per Capita", y = "Ratio of Suicides", title = "GDP per Capita vs Ratio of Suicides for Top 10 Countries") +
  theme_minimal() +
  theme(legend.position = "right")

# Calculate the correlation between GDP per capita and suicide rate for each country
correlation_df <- df_gdp_total %>%
  group_by(country) %>%
  summarise(correlation = cor(gdp_per_capita, suicide_ratio, use = "complete.obs")) %>%
  arrange(desc(correlation))

# Display the result
print(correlation_df)

# Create a bar plot of the correlation coefficients
ggplot(data = correlation_df, aes(x = reorder(country, correlation), y = correlation, fill = correlation)) +
  geom_bar(stat = "identity", width = 0.7) +  # Adjust bar width
  scale_fill_gradient(low = "yellow", high = "red") +  # Color palette "YlOrRd"
  labs(x = "Countries", y = "Correlation Coefficient", title = "Correlation Coefficient") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, size = 6),  # Rotate and reduce size of x-axis text
        plot.title = element_text(hjust = 0.5),  # Center title
        panel.grid.major.x = element_blank(),  # Remove major grid lines on x-axis
        panel.spacing.x = unit(1, "cm"))  # Increase space between bars
