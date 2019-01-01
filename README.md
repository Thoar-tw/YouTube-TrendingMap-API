# YouTube Trending Map API

[ ![Codeship Status for Thoar-tw/YouTube-TrendingMap-API](https://app.codeship.com/projects/42410180-eb20-0136-4343-567225019dfc/status?branch=master)](https://app.codeship.com/projects/319812)

## Overview
A web API that allows users to retrieve YouTube HOT & TOP videos from various **countries**, **continents**, toward **global**.

## Routes

### Root check

`GET /`

Status:

- 200: API server running (happy)

### Get a list of YouTube hot videos in a country(with it's region code)

`GET /hot_videos/{region_code}/{category_id}`

Status

- 200: video list returned (happy)
- 404: invalid region_code or category_id (sad)
- 500: problems getting the video list (bad)

### Get a list of YouTube top viewed videos in the global world

`GET /top_videos/global/{category_id}`

Status

- 200: video list returned (happy)
- 404: invalid category_id (sad)
- 500: problems getting the video list (bad)

### Get a list of YouTube top viewed videos within a continent

`GET /top_videos/continent/{continent_name}/{category_id}`

Status

- 200: video list returned (happy)
- 404: invalid continent_name or category_id (sad)
- 500: problems getting the video list (bad)

### Get a list of YouTube top viewed videos in a country(with it's region code)

`GET /top_videos/continent/{region_code}/{category_id}`

Status

- 200: video list returned (happy)
- 404: invalid region_code or category_id (sad)
- 500: problems getting the video list (bad)

## Acknowledgement
This project is the term project of the Service Oriented Architecture (SOA) lecture in NTHU, lectured by professor [Soumya Ray](https://soumyaray.com/).
We thank for his excellent lectures, valuable feedback and helpful discussions.
