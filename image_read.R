library(tidyverse)
library(magick)

im <- image_read("new_abn_graph.jpg")
im_proc <- im %>%
  image_channel("saturation")

plot(im_proc)
im_proc2 <- im_proc %>%
  image_threshold("black", "85%")


plot(im_proc2)

im_proc3 <- im_proc2 %>%
  image_threshold("white", "30%")

plot(im_proc3)

im_proc4 <- im_proc3 %>%
  image_negate()

plot(im_proc4)


dat <- image_data(im_proc4)[1,,] %>%
  as.data.frame() %>%
  mutate(Row = 1:nrow(.)) %>%
  select(Row, everything()) %>%
  mutate_all(as.character) %>%
  gather(key = Column, value = value, 2:ncol(.)) %>%
  mutate(Column = as.numeric(gsub("V", "", Column)),
         Row = as.numeric(Row),
         value = ifelse(value == "00", NA, 1)) %>%
  filter(!is.na(value))

ggplot(data = dat, aes(x = Row, y = Column, colour = (Column > 850))) +
  geom_point() +
  scale_y_continuous(trans = "reverse") +
  scale_colour_manual(values = c("red4", "blue4")) +
  theme(legend.position = "off")

