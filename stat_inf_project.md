---
title: "Statistical Inference with the GSS data"
output: 
  html_document: 
    fig_height: 4
    fig_width: 9
    highlight: pygments
    theme: yeti
    toc: yes
    keep_md: yes
---

## Summary

This paper forms the final assessment for the Duke University Inferential Statistics course.

The objective is to develop a research question using the General Social Survey (GSS) dataset and then conduct exploratory and inferential analysis in response.

This paper asks "*Is there a link between a person's concern regarding spending on crime and their socio-economic status?*"

The analysis examines responses to the survey question regarding current spending on halting rising crime and looks at the proportion of each socio-economic group that responded with either too much, too little or about right.

Using the Chi-square test of independence to compare observed and expected proportions, it was determined beyond any reasonable doubt that there is indeed a relationship between the two.

## Setup

### Load packages


```r
library(ggplot2)
library(dplyr)
library(tidyr)
library(statsr)
library(ggthemes)
library(plotly)
library(kableExtra)

source('http://bit.ly/dasi_inference')
```

### Set Global Defaults


```r
# set defaults: cache chunks to speed compiling subsequent edits.
knitr::opts_chunk$set(cache=TRUE, echo = TRUE)
```

### Load data

The data file is in Rdata (gz compressed) format and is obtained and loaded using the code below.


```r
download.file(
  "https://d3c33hcgiwev3.cloudfront.net/_5db435f06000e694f6050a2d43fc7be3_gss.Rdata?Expires=1645056000&Signature=Yxc6MGpqzYdGYkkSlHfGY5tz2VRAWy2eY3IcB-ZvqUWvfiGL3j3Y9wyM-xpSdvACKQiZLHFHDqNtpIZt2TnduwIyKva9bwI1OsuBZAiSiiikJ0mu~LwybmnJs-i8A3AdPACBXMWZuv4440Abg4qPTyti3Lj7sO8~u2xfSoAdyx8_&Key-Pair-Id=APKAJLTNE6QMUY6HBC5A",
  "./gss.Rdata", 
  method = "curl"
  )
load("./gss.Rdata")
dim(gss)
```

```
## [1] 57061   114
```

------------------------------------------------------------------------

## Part 1: Data

The data set consists of 57061 observations, each a set of responses from one respondent. Observations have 114 variables - either direct answers to survey questions, or calculated values based on responses.

The full description of each variable is available in the [codebook](https://d3c33hcgiwev3.cloudfront.net/_8abbe344133a7a8c98cfabe01a5075c2_gss.html?Expires=1645056000&Signature=ArIdHL6zIGTeHp13k0jkaRdxchTEPHXhDk7eMKh3wCCLkjXBThoyM9MERi80Y7MGW2ckE1W7ySyqm5lP-8v0HSY5Ufv90pB~F~dH-HYWc0LR0wD~7dFKyksUZOXGVUottpH76dImCJimFKUJbw-Jgpe5gl8db~B4fEekAZTZ-WU_&Key-Pair-Id=APKAJLTNE6QMUY6HBC5A).

### Abstract for the GSS Data Set

Since 1972, the General Social Survey (GSS) has been monitoring societal change and studying the growing complexity of American society. The GSS aims to gather data on contemporary American society in order to monitor and explain trends and constants in attitudes, behaviors, and attributes; to examine the structure and functioning of society in general as well as the role played by relevant subgroups; to compare the United States to other societies in order to place American society in comparative perspective and develop cross-national models of human society; and to make high-quality data easily accessible to scholars, students, policy makers, and others, with minimal cost and waiting.

GSS questions cover a diverse range of issues including national spending priorities, marijuana use, crime and punishment, race relations, quality of life, confidence in institutions, and sexual behavior.

The GSS has a "replicating core" that emphasizes collection of data on social trends through exact replication of question wording over time. Core items fall into two major categories--- socio-demographic/background measures, and replicated measurements on social and political attitudes and behaviors.

The target population of the GSS is adults (18+) living in households in the United States. The GSS sample is drawn using an area probability design that randomly selects respondents in households across the United States to take part in the survey. Respondents that become part of the GSS sample are from a mix of urban, suburban, and rural geographic areas. Participation in the study is strictly voluntary. However, because only about a few thousand respondents are interviewed in the main study, every respondent selected is very important to the results.

The survey is conducted face-to-face with an in-person interview by [NORC at the University of Chicago](https://en.wikipedia.org/wiki/NORC_at_the_University_of_Chicago "NORC at the University of Chicago"). The survey was conducted every year from 1972 to 1994 (except in 1979, 1981, and 1992). Since 1994, it has been conducted every other year. The survey takes about 90 minutes to administer.

*Excerpted from [GSS project description](http://www.norc.org/Research/Projects/Pages/general-social-survey.aspx), the [GSS Wikipedia Page](https://en.wikipedia.org/wiki/General_Social_Survey#Methodology) and [The General Social Survey (GSS)The Next Decade and Beyond](https://www.nsf.gov/pubs/2007/nsf0748/nsf0748_3.pdf)*

### Type of Study

This is an observational study due to the nature of data collection. It only establishes associations and trends and cannot be used to infer causality.

### Generalizability

While no random assignment was used in the surveys, and the sampling methodology is randomised, caution should be exercised before considering this data to be generalizable to the entire American population due to possible sources of bias (see below).

### Possible Sources of Bias

-   The sample set will represent those who have both the time and inclination to answer a 90 minute questionnaire.
-   The sample set will most likely favour those who do not have a mistrust of authority or giving out personal information (which may produce a bias against certain segments of society).
-   Respondents may alter their responses in a variety of ways because the answers to the interview questions are not validated, such as expressing desirable traits while under-reporting undesirable ones. This is highlighted in the following analysis where few people identified as either "lower" class or "high" class despite their socio-economic index suggesting otherwise. Negative connotations with both of these terms may influence people to self-identify with different classes.
-   From 1972 to 1994, the survey was conducted annually (except in 1979, 1981, and 1992). It has been held every other year since 1994. Care should be exercised when making analysis of trends that span these changes in frequency.

------------------------------------------------------------------------

## Part 2: Research question

Two years ago, I moved from a country with a very low crime incidence to a country, and city, with a high and rising crime rate. The highest rate of increase in the level of crime is disproportionally in the poorer suburbs of the city. While you would think that those most affected would be the most concerned, there is a general sense of apathy towards the situation in those neighbourhoods: "It is what it is, the police won't help us".

I'm interested to see if the data would suggest that there is a similar attitude in the US.

> Is there a link between a person's concern regarding spending on crime and their socio-economic status?

The question is an important part of understanding the broader picture of not only how crime is perceived across the socio-economic spectrum, but also as an indication of trust levels those groups have with authorities in tackling the crime problem.

There are three competing schools of thought here:

1.  Crime affects lower socio-economic groups disproportionally. Those who face crime on a regular basis will be most concerned. This would be reflected by a higher proportion of people in the lower groups indicating a concern over crime.
2.  People fear the unknown. Those that face crime on a regular basis will more likely be conditioned towards the situation, whereas those who rarely come into contact with it will have a greater fear and therefore greater concern.
3.  People are equally concerned over crime across all socio-economic groups, it's a universal concern.

Point 3 then becomes our null hypothesis, while 1 & 2 collectively becomes our alternative hypothesis.

$H_0: p_{class}\ and\ p_{crime}\ are\ independent$,\
$H_A: p_{class}\ and\ p_{crime}\ are\ dependent$

*where* $p_{class}$ *is the proportion in each class and* $p_{crime}$ *is the proportion of responses to the crime question.*

In other words:

-   The null hypothesis says that for each class, the proportion that respond with each level of concern will be, within a given margin of error, the same as that given by the overall proportion of classes. By definition, this also means that the proportion in any class that respond with each level of crime concern will be reflected by the overall proportion of responses within a margin of error.
-   The alternative states that the proportions will be outside of this margin of error, indicating a relationship between the two.

The variables of interest here will be:

+----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| class    | SUBJECTIVE CLASS IDENTIFICATION                                                                                                                                                                                                                                                                                                  |
|          |                                                                                                                                                                                                                                                                                                                                  |
|          | If you were asked to use one of four names for your social class, which would you say you belong in: the lower class, the working class, the middle class, or the upper class?                                                                                                                                                   |
|          |                                                                                                                                                                                                                                                                                                                                  |
|          | LOWER CLASS, WORKING CLASS, MIDDLE CLASS, UPPER CLASS, NO CLASS                                                                                                                                                                                                                                                                  |
+----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| natcrime | HALTING RISING CRIME RATE                                                                                                                                                                                                                                                                                                        |
|          |                                                                                                                                                                                                                                                                                                                                  |
|          | We are faced with many problems in this country, none of which can be solved easily or inexpensively. I'm going to name some of these problems, and for each one I'd like you to tell me whether you think we're spending too much money on it, too little money, or about the right amount. i.e. Halting the rising crime rate. |
|          |                                                                                                                                                                                                                                                                                                                                  |
|          | TOO LITTLE, ABOUT RIGHT, TOO MUCH                                                                                                                                                                                                                                                                                                |
+----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| sei      | RESPONDENT SOCIOECONOMIC INDEX                                                                                                                                                                                                                                                                                                   |
|          |                                                                                                                                                                                                                                                                                                                                  |
|          | Calculated value, numeric (1 - 99.7)                                                                                                                                                                                                                                                                                             |
|          |                                                                                                                                                                                                                                                                                                                                  |
|          | See [Appendix](#appendix) for explanation of this variable.                                                                                                                                                                                                                                                                      |
|          |                                                                                                                                                                                                                                                                                                                                  |
|          | This variable will be used to cross-check the results of the hypothesis test on the class variable where respondents self-identifying as either UPPER or LOWER CLASS were few.                                                                                                                                                   |
|          |                                                                                                                                                                                                                                                                                                                                  |
|          | Note that the sei variable is not recorded until 1988, nor for the 2012 survey.                                                                                                                                                                                                                                                  |
+----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

------------------------------------------------------------------------

## Part 3: Exploratory data analysis

### Data Preparation

To prepare the data subset, we eliminate the `NA`'s and invalid values in `class`, `sei` & `natcrime` from the `gss` data table, select only those columns of interest and drop any unused factor levels.


```r
#sei: Missing-data codes: -1.0,99.8,99.9
dfSubset <- gss %>%
    filter(
        !is.na(natcrime), 
        !is.na(class), 
        !is.na(sei),
        class != 'No Class',
        sei >= 0 & sei < 99.8,
        ) %>%
    select(year, class, sei, natcrime) %>%
    droplevels()
```

Because of the limit of years that `sei` was recorded, this sets the boundaries of the surveys from 1988 to 2010 (inclusive).

Next, we create a factor of 4 levels based on the quarterly quantiles of the `sei` variable and label those accordingly:


```r
q_sei <- quantile(dfSubset$sei, c(1:3)/4)
q_sei
```

```
##  25%  50%  75% 
## 32.4 39.0 63.5
```

```r
dfSubset <- dfSubset %>%
    mutate(socioeconomic = factor(
        case_when(
            sei <= q_sei[1] ~ '1',
            sei > q_sei[1] & sei <= q_sei[2] ~ '2',
            sei > q_sei[2] & sei <= q_sei[3] ~ '3',
            TRUE ~ '4'
            ),
        labels=c('Lower', 'Lower Middle', 'Upper Middle', 'Upper')
        ) 
    )

dfSubset %>% sample_n(10)
```

```
##    year         class  sei    natcrime socioeconomic
## 1  1996 Working Class 36.5  Too Little  Lower Middle
## 2  2002  Middle Class 37.7 About Right  Lower Middle
## 3  1994 Working Class 29.5  Too Little         Lower
## 4  2010  Middle Class 39.0 About Right  Lower Middle
## 5  1996 Working Class 44.8  Too Little  Upper Middle
## 6  1994 Working Class 69.2  Too Little         Upper
## 7  1996 Working Class 38.4 About Right  Lower Middle
## 8  2000   Lower Class 28.4  Too Little         Lower
## 9  2008 Working Class 33.1 About Right  Lower Middle
## 10 2000 Working Class 63.5 About Right  Upper Middle
```

### Preliminary Analysis

Because the surveys cover a long period of time (22 years), it's a good idea to make sure we're not incorporating any long term trends over time and skewing the data.


```r
dfclassyearcrime <- dfSubset %>% 
    group_by(class, year, natcrime) %>%
    summarise(n=n()) %>%
    mutate(proportion = round(100 * n / sum(n), 1)) %>%
    filter(natcrime=='Too Little') %>%
    select(-n, -natcrime) %>%
    rename(Year = year) 

p <- ungroup(dfclassyearcrime) %>%
    pivot_wider(names_from = class, values_from = proportion) %>%
    plot_ly(x=~Year, y=~`Lower Class`, name='Lower Class', type='scatter', mode='lines') %>%
    add_trace(y=~`Working Class`, name='Working Class', mode='lines') %>%
    add_trace(y=~`Middle Class`, name='Middle Class', mode='lines') %>%
    add_trace(y=~`Upper Class`, name='Upper Class', mode='lines') %>% 
    config(displayModeBar = F) %>%
    layout(
        xaxis=list(fixedrange=T),
        yaxis=list(title="Proportion of Class (%)")
        ) 
    
t <- dfclassyearcrime %>%
    pivot_wider(names_from = Year, values_from = proportion) %>%
    kbl() %>% 
    kable_styling(bootstrap_options = c("condensed"))
```

::: {align="center" style="font-size: 120%;font-weight: bold;"}
Respondents Answering 'Too Little' to the National Crime Spending Question 1988-2010
:::


```r
p
```

```{=html}
<div id="htmlwidget-e6ad30e4a7a844afdd23" style="width:912px;height:336px;" class="plotly html-widget"></div>
<script type="application/json" data-for="htmlwidget-e6ad30e4a7a844afdd23">{"x":{"visdat":{"5cdc53406e2e":["function () ","plotlyVisDat"]},"cur_data":"5cdc53406e2e","attrs":{"5cdc53406e2e":{"x":{},"y":{},"mode":"lines","name":"Lower Class","alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter"},"5cdc53406e2e.1":{"x":{},"y":{},"mode":"lines","name":"Working Class","alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter","inherit":true},"5cdc53406e2e.2":{"x":{},"y":{},"mode":"lines","name":"Middle Class","alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter","inherit":true},"5cdc53406e2e.3":{"x":{},"y":{},"mode":"lines","name":"Upper Class","alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter","inherit":true}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"xaxis":{"domain":[0,1],"automargin":true,"fixedrange":true,"title":"Year"},"yaxis":{"domain":[0,1],"automargin":true,"title":"Proportion of Class (%)"},"hovermode":"closest","showlegend":true},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false,"displayModeBar":false},"data":[{"x":[1988,1989,1990,1991,1993,1994,1996,1998,2000,2002,2004,2006,2008,2010],"y":[69.2,83.9,68,77.4,73.2,86.5,72.7,71.2,63.6,68.8,65.9,65.9,66.7,68.6],"mode":"lines","name":"Lower Class","type":"scatter","marker":{"color":"rgba(31,119,180,1)","line":{"color":"rgba(31,119,180,1)"}},"error_y":{"color":"rgba(31,119,180,1)"},"error_x":{"color":"rgba(31,119,180,1)"},"line":{"color":"rgba(31,119,180,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[1988,1989,1990,1991,1993,1994,1996,1998,2000,2002,2004,2006,2008,2010],"y":[68.6,75.8,74.2,67.5,72.1,79.3,74.4,68.9,66.2,60.7,63.7,66.8,66.2,62.5],"mode":"lines","name":"Working Class","type":"scatter","marker":{"color":"rgba(255,127,14,1)","line":{"color":"rgba(255,127,14,1)"}},"error_y":{"color":"rgba(255,127,14,1)"},"error_x":{"color":"rgba(255,127,14,1)"},"line":{"color":"rgba(255,127,14,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[1988,1989,1990,1991,1993,1994,1996,1998,2000,2002,2004,2006,2008,2010],"y":[73.2,72.9,70.8,64.5,75.7,75.6,63.8,56.3,55.4,53.2,53.6,59.7,59.3,55],"mode":"lines","name":"Middle Class","type":"scatter","marker":{"color":"rgba(44,160,44,1)","line":{"color":"rgba(44,160,44,1)"}},"error_y":{"color":"rgba(44,160,44,1)"},"error_x":{"color":"rgba(44,160,44,1)"},"line":{"color":"rgba(44,160,44,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[1988,1989,1990,1991,1993,1994,1996,1998,2000,2002,2004,2006,2008,2010],"y":[88.2,80,72.2,58.3,66.7,75,74.4,62.7,60,55.1,45,38.1,40.6,38.7],"mode":"lines","name":"Upper Class","type":"scatter","marker":{"color":"rgba(214,39,40,1)","line":{"color":"rgba(214,39,40,1)"}},"error_y":{"color":"rgba(214,39,40,1)"},"error_x":{"color":"rgba(214,39,40,1)"},"line":{"color":"rgba(214,39,40,1)"},"xaxis":"x","yaxis":"y","frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.2,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```

```r
t
```

<table class="table table-condensed" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> class </th>
   <th style="text-align:right;"> 1988 </th>
   <th style="text-align:right;"> 1989 </th>
   <th style="text-align:right;"> 1990 </th>
   <th style="text-align:right;"> 1991 </th>
   <th style="text-align:right;"> 1993 </th>
   <th style="text-align:right;"> 1994 </th>
   <th style="text-align:right;"> 1996 </th>
   <th style="text-align:right;"> 1998 </th>
   <th style="text-align:right;"> 2000 </th>
   <th style="text-align:right;"> 2002 </th>
   <th style="text-align:right;"> 2004 </th>
   <th style="text-align:right;"> 2006 </th>
   <th style="text-align:right;"> 2008 </th>
   <th style="text-align:right;"> 2010 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Lower Class </td>
   <td style="text-align:right;"> 69.2 </td>
   <td style="text-align:right;"> 83.9 </td>
   <td style="text-align:right;"> 68.0 </td>
   <td style="text-align:right;"> 77.4 </td>
   <td style="text-align:right;"> 73.2 </td>
   <td style="text-align:right;"> 86.5 </td>
   <td style="text-align:right;"> 72.7 </td>
   <td style="text-align:right;"> 71.2 </td>
   <td style="text-align:right;"> 63.6 </td>
   <td style="text-align:right;"> 68.8 </td>
   <td style="text-align:right;"> 65.9 </td>
   <td style="text-align:right;"> 65.9 </td>
   <td style="text-align:right;"> 66.7 </td>
   <td style="text-align:right;"> 68.6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Working Class </td>
   <td style="text-align:right;"> 68.6 </td>
   <td style="text-align:right;"> 75.8 </td>
   <td style="text-align:right;"> 74.2 </td>
   <td style="text-align:right;"> 67.5 </td>
   <td style="text-align:right;"> 72.1 </td>
   <td style="text-align:right;"> 79.3 </td>
   <td style="text-align:right;"> 74.4 </td>
   <td style="text-align:right;"> 68.9 </td>
   <td style="text-align:right;"> 66.2 </td>
   <td style="text-align:right;"> 60.7 </td>
   <td style="text-align:right;"> 63.7 </td>
   <td style="text-align:right;"> 66.8 </td>
   <td style="text-align:right;"> 66.2 </td>
   <td style="text-align:right;"> 62.5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Middle Class </td>
   <td style="text-align:right;"> 73.2 </td>
   <td style="text-align:right;"> 72.9 </td>
   <td style="text-align:right;"> 70.8 </td>
   <td style="text-align:right;"> 64.5 </td>
   <td style="text-align:right;"> 75.7 </td>
   <td style="text-align:right;"> 75.6 </td>
   <td style="text-align:right;"> 63.8 </td>
   <td style="text-align:right;"> 56.3 </td>
   <td style="text-align:right;"> 55.4 </td>
   <td style="text-align:right;"> 53.2 </td>
   <td style="text-align:right;"> 53.6 </td>
   <td style="text-align:right;"> 59.7 </td>
   <td style="text-align:right;"> 59.3 </td>
   <td style="text-align:right;"> 55.0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Upper Class </td>
   <td style="text-align:right;"> 88.2 </td>
   <td style="text-align:right;"> 80.0 </td>
   <td style="text-align:right;"> 72.2 </td>
   <td style="text-align:right;"> 58.3 </td>
   <td style="text-align:right;"> 66.7 </td>
   <td style="text-align:right;"> 75.0 </td>
   <td style="text-align:right;"> 74.4 </td>
   <td style="text-align:right;"> 62.7 </td>
   <td style="text-align:right;"> 60.0 </td>
   <td style="text-align:right;"> 55.1 </td>
   <td style="text-align:right;"> 45.0 </td>
   <td style="text-align:right;"> 38.1 </td>
   <td style="text-align:right;"> 40.6 </td>
   <td style="text-align:right;"> 38.7 </td>
  </tr>
</tbody>
</table>

There is indeed a lot of change over the period. As there was a higher frequency of surveys prior to 1994, we'll exclude those to avoid skewing the subset towards those earlier years. Additionally, since we're looking at what the latest data looked like rather than trends over time, we will limit the data to the last 10 years of the sub-setted data (2000 - 2010 inclusive).

We can see from the chart above that, over time, there's indication that there may have been a reverse in the order of most concern amongst those that responded to this survey. This would be an interesting study in itself, but one that is beyond this research question.


```r
dfSubset <- dfSubset %>%
    filter(year >= 2000)
```

### Distribution of Variables


```r
bp_crime <- ggplot(dfSubset, aes(x=natcrime)) + 
    geom_bar(fill='orange') +
    theme_excel_new() +
    theme(plot.margin = margin(0, 0, 0, 0, "cm"))

bp_class <- ggplot(dfSubset, aes(x=class)) + 
    geom_bar(fill='orange') +
    theme_excel_new() +
    theme(plot.margin = margin(0, 0, 0, 0, "cm"))

bp_se <- ggplot(dfSubset, aes(x=socioeconomic)) + 
    geom_bar(fill='orange') +
    theme_excel_new() +
    theme(plot.margin = margin(0, 0, 0, 0, "cm"))
```

::: columns
::: {.column width="35%"}

```r
bp_crime
```

![](stat_inf_project_files/figure-html/bp_crime-1.png)<!-- -->
:::

::: {.column width="5%"}
 
:::

::: {.column width="60%"}
\
\
\
**Distribution of Responses to Crime Spending**

-   The distribution is heavily weighted on the 'Too Little' response

-   Care will be needed to ensure there are sufficient responses from each class to make an analysis meaningful.
:::
:::

::: columns
::: {.column width="35%"}

```r
bp_class
```

![](stat_inf_project_files/figure-html/bp_class-1.png)<!-- -->
:::

::: {.column width="5%"}
 
:::

::: {.column width="60%"}
\
\
\
**Distribution of Responses to Class**

-   The distribution is heavily weighted on the 'Working Class' and 'Middle Class' responses

-   Again, care will be needed to ensure there are sufficient responses from those classes in each crime response category to make an analysis meaningful.
:::
:::

::: columns
::: {.column width="35%"}

```r
bp_se
```

![](stat_inf_project_files/figure-html/bp_se-1.png)<!-- -->
:::

::: {.column width="5%"}
 
:::

::: {.column width="60%"}
\
\
\
**Distribution of Socio-Economic band**

-   The distribution is fairly even as expected since this was created from quantile boundaries.

-   Analysis needed to see if this is the better variable to use for inference models.
:::
:::

### Two-way Table of Observed Counts


```r
allClasses = dfSubset %>% 
    group_by(natcrime) %>%
    summarise(n=n()) %>%
    mutate(class='All Classes') %>%
    relocate(class)

dfclasscrime <- dfSubset %>% 
    group_by(class, natcrime) %>%
    summarise(n=n()) %>%
    rbind(allClasses) %>%
    mutate(
        proportion = paste0(
            as.character(n),
            ' (', 
            format(round(100 * n / sum(n), 1), nsmall=1), 
            '%)'
            )
        ) %>%
    select(-n) %>%
    pivot_wider(names_from = class, values_from = proportion) 

colTotals <- dfSubset %>%
    group_by(class) %>%
    summarise(n=n()) %>%
    pivot_wider(names_from = class, values_from = n) %>%
    mutate(natcrime="Total", `All Classes`="") %>%
    relocate(natcrime)

dfclasscrime <- dfclasscrime %>%
    rbind(colTotals) %>%
    rename(Response=natcrime)

t <- dfclasscrime %>%
    kbl() %>% 
    kable_styling(bootstrap_options = c("condensed"))
```

::: {align="center" style="font-size: 120%;font-weight: bold;"}
Two-way Table for Respondents Answering the National Crime Spending Question 2000-2010
:::


```r
t
```

<table class="table table-condensed" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Response </th>
   <th style="text-align:left;"> Lower Class </th>
   <th style="text-align:left;"> Working Class </th>
   <th style="text-align:left;"> Middle Class </th>
   <th style="text-align:left;"> Upper Class </th>
   <th style="text-align:left;"> All Classes </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Too Little </td>
   <td style="text-align:left;"> 289 (66.7%) </td>
   <td style="text-align:left;"> 2032 (64.4%) </td>
   <td style="text-align:left;"> 1752 (55.9%) </td>
   <td style="text-align:left;"> 113 (47.3%) </td>
   <td style="text-align:left;"> 4186 (60.1%) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> About Right </td>
   <td style="text-align:left;"> 108 (24.9%) </td>
   <td style="text-align:left;"> 932 (29.5%) </td>
   <td style="text-align:left;"> 1198 (38.2%) </td>
   <td style="text-align:left;"> 107 (44.8%) </td>
   <td style="text-align:left;"> 2345 (33.7%) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Too Much </td>
   <td style="text-align:left;"> 36 ( 8.3%) </td>
   <td style="text-align:left;"> 190 ( 6.0%) </td>
   <td style="text-align:left;"> 184 ( 5.9%) </td>
   <td style="text-align:left;"> 19 ( 7.9%) </td>
   <td style="text-align:left;"> 429 ( 6.2%) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Total </td>
   <td style="text-align:left;"> 433 </td>
   <td style="text-align:left;"> 3154 </td>
   <td style="text-align:left;"> 3134 </td>
   <td style="text-align:left;"> 239 </td>
   <td style="text-align:left;">  </td>
  </tr>
</tbody>
</table>

-   These are observed counts with percentage showing the proportion of that class that responded with each option.
-   Expected counts are calculated using the `dasi_inference` algorithm in the next section.
-   Total columns both add up to the number of observations in the sub-setted data (6960).
-   Of the 6960 observations in the sub-setted data, 60.1% responded that too little is spent on crime, 33.7% responded that current spending is about right, while 6.2% said the amount was too much.
-   The maximum proportional response for Too Little and Too Much is found in the Lower Class indicating a more polarized opinion amongst Lower Class respondents may exist, although without studying the margin of error, this may not be true.
-   Proportionally, Lower and Working Class respondents show a higher level of concern that not enough is being spent on crime, while Upper Class shows the lowest level of concern.

------------------------------------------------------------------------

## Part 4: Inference

Because we are comparing two categorical variables (each with more than 2 levels) as proportions, we will perform a Hypothesis Test using Chi-square test of independence.

No confidence-interval inference is possible for this type of analysis.

### Hypothesis

To recap, the hypothesis to be tested is:

$H_0: p_{class}\ and\ p_{crime}\ are\ independent$,\
$H_A: p_{class}\ and\ p_{crime}\ are\ dependent$

-   The null hypothesis says that for each class, the proportion that respond with each level of concern will be, within a given margin of error, the same as that given by the overall proportion.
-   The alternative states that the proportions will be outside of this margin of error, indicating a relationship between the two.

### Conditions Test

**Independence**

-   Although there are some concerns regarding bias highlighted in Data section, we are assuming that respondents are independent of each other.
-   The groups all meet the requirement for being less than 10% of the population.
-   Each group is independent of each other with no possibility of one respondent belonging to more than one.

**Sample Size**

-   Each cell has at least 5 responses.

The sub-setted data meets the requirements for the Chi-square test of independence.

### Methodology

The chi-square procedure assesses whether the data provide enough evidence that a true relationship between the two variables exists in the population.

The idea behind the test is measuring how far the observed data are from the null hypothesis by comparing the observed counts to the expected counts---the counts that we would expect to see (instead of the observed ones) had the null hypothesis been true. The expected count of each cell is calculated as follows:

$$Expected\ Count = \frac{Column\ Total\ \times\ Row\ Total}{Table\ Total}$$

Degrees of freedom is calculated as:

$$
Degrees\ of\ freedom\ (df) = (Rows-1)\times(Columns-1)=2\times3=6
$$

The measure of the difference between the observed and expected counts is the chi-square test statistic, whose null distribution is called the chi-square distribution. The chi-square test statistic is calculated as follows:

$$
χ2 = \displaystyle\sum_{all\ cells}\frac{(Observed\ Count - Expected\ Count)^2}{Expected\ Count}
$$

The $p$-value is the probability of observing χ^2^ at least as large as the one observed, the probability of getting counts like those observed, assuming that the two variables are not related (which is what is claimed by the null hypothesis).

The expected counts, χ^2^ and $p$-value will be calculated from the sub-setted data using the `inference()` function from the `dasi_inference` package:

-   Categorical variable (`x`) is the class of the respondent (`class`).
-   Response variable (`y`) is how the respondent answered the question regarding crime spending (`natcrime`).
-   We use `proportion` for the `estimation` type and run a test of `ht` type (hypothesis test).
-   `method` is `theoretical` as our expected sample size condition is met
-   `alternative` is `greater` since we are looking for the possibility that χ^2^ is at least greater than the one observed.
-   Finally, we set the number of simulations to run `nsim` to 100,000.


```r
inference(
    y=dfSubset$natcrime, 
    x=dfSubset$class,
    est='proportion', 
    type='ht', 
    method='theoretical', 
    alternative = 'greater', 
    nsim = 100000
    )
```

```
## Response variable: categorical, Explanatory variable: categorical
## Chi-square test of independence
## 
## Summary statistics:
##              x
## y             Lower Class Working Class Middle Class Upper Class  Sum
##   Too Little          289          2032         1752         113 4186
##   About Right         108           932         1198         107 2345
##   Too Much             36           190          184          19  429
##   Sum                 433          3154         3134         239 6960
```

```
## H_0: Response and explanatory variable are independent.
## H_A: Response and explanatory variable are dependent.
## Check conditions: expected counts
##              x
## y             Lower Class Working Class Middle Class Upper Class
##   Too Little       260.42       1896.93      1884.90      143.74
##   About Right      145.89       1062.66      1055.92       80.53
##   Too Much          26.69        194.41       193.17       14.73
## 
## 	Pearson's Chi-squared test
## 
## data:  y_table
## X-squared = 87.447, df = 6, p-value < 2.2e-16
```

![](stat_inf_project_files/figure-html/class_inference-1.png)<!-- -->

This extremely low $p$-value of 2.2e-16 implies that there is a negligible probability that the observed results are by chance only and easily meets the requirement to reject the null hypothesis at any confidence level.

### Alternative Test

Although we can't produce a confidence interval test for this analysis, we can look at the socio-economic classifications created earlier and see if these produce a similar result.

The independence conditions for this variable still hold since they are from the same data sample and recipients can only belong to one group each.

Sample size is easily met as each group will represent approximately one quarter of the sub-setted recipients.

For this, we just need to swap out `class` for `socioeconomic` as the explanatory variable in the inference function:


```r
inference(
    y=dfSubset$natcrime, 
    x=dfSubset$socioeconomic,
    est='proportion', 
    type='ht', 
    method='theoretical', 
    alternative = 'greater', 
    nsim = 100000
)
```

```
## Response variable: categorical, Explanatory variable: categorical
## Chi-square test of independence
## 
## Summary statistics:
##              x
## y             Lower Lower Middle Upper Middle Upper  Sum
##   Too Little   1118         1048         1059   961 4186
##   About Right   496          448          681   720 2345
##   Too Much      122          102          109    96  429
##   Sum          1736         1598         1849  1777 6960
```

```
## H_0: Response and explanatory variable are independent.
## H_A: Response and explanatory variable are dependent.
## Check conditions: expected counts
##              x
## y               Lower Lower Middle Upper Middle   Upper
##   Too Little  1044.09       961.10      1112.06 1068.75
##   About Right  584.90       538.41       622.97  598.72
##   Too Much     107.00        98.50       113.97  109.53
## 
## 	Pearson's Chi-squared test
## 
## data:  y_table
## X-squared = 89.266, df = 6, p-value < 2.2e-16
```

![](stat_inf_project_files/figure-html/se_inference-1.png)<!-- -->

This test yields a similarly high χ^2^ value and resulting low $p$-value.

The graph above may also suggest a secondary grouping showing close agreement between those below the average socio-economic index and those above. This is not a conclusion you can draw from this analysis however.

### Conclusion

With such a low $p$-value, the null hypothesis that there is no relationship between class (or socio-economic status) and concern over spending on crime is easily rejected, the data provides convincing evidence for the alternative hypothesis that there is a relationship.

It should be noted that this test does not explain the nature of the relationship; it simply confirms its existence.

Because we are comparing multi-level categorical variables, only a Chi-square test of independence, and no confidence interval method is possible to back up the findings. It was however possible to produce similar results using both the self-identified class category and the calculated SEI (socio-economic index).

Even though the tests yielded an extremely low $p$-value, this is an observational study. As a result, we cannot claim that class causes the level of concern about spending on crime, only that there is a very strong correlation.

Confounders could be that lower-income people may have a higher level of mistrust of authority and are less likely to give out personal information to a survey, or that attitudes to crime and authority are linked to race, and those races are not even represented across the socio-economic groupings.

It should be remembered that the survey question asks the respondent "*whether you think we're spending too much money on* $[$*halting rising crime*$]$*, too little money, or about the right amount*". This is not the same question as asking the recipient if they are concerned about the crime rate.

It is also easy to speculate that the first school of thought discussed in the question (those who face crime on a regular basis will be most concerned) is supported; however, this was not tested in the inference model, and the survey data does not include information to suggest that people from lower socio-economic groups face crime at a higher rate. This is for a separate study.

Further studies might include:

-   Crime rate in respondents home and work neighbourhoods
-   Perception of crime as a problem
-   Personal experience of crime
-   Trust in police, judicial system and government to tackle crime
-   Perceptions of equality in those systems (do they tackle crime across all socio-economic groups equally, are resources spread proportionally etc.)
-   Personal experience of police/judicial system

------------------------------------------------------------------------

## Appendix {#appendix}

### Note about SEI

SEI scores were originally calculated by Otis Dudley Duncan based on NORC's 1947 North-Hatt prestige study and the 1950 U.S. Census. Duncan regressed prestige scores for 45 occupational titles on education and income to produce weights that would predict prestige. This algorithm was then used to calculate SEI scores for all occupational categories employed in the 1950 Census classification of occupations. Similar procedures have been used to produce SEI scores based on later NORC prestige studies and censuses.

The GSS contains several sets of SEI scores. They all used procedures similar to those employed by Duncan. For cases coded according to the 1970 US Census codes there are SEI scores developed by Lloyd V. Temme (See Appendix G). These exist for respondent (DOTPRES), spouse (SPDOTPRE), and father (PADOTPRE). For cases coded according to the 1980 US Census codes there are SEI scores developed by Nakao and Treas as part of the GSS's 1989 occupational prestige study (see above). These exist for respondent (SEI), respondent's first occupation (FIRSTSEI), father (PASEI), mother (MASEI), and spouse (SPSEI).

Excerpt from the [GSS Codebook Appendix](https://gss.norc.org/Documents/codebook/GSS_Codebook_AppendixG.pdf)

------------------------------------------------------------------------

\
\
\
\
\
\
