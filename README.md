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

`POST /hot_videos/{region_code}/{category_id}`

Status

- 200: video list returned (happy)
- 404: invalid region_code or category_id (sad)
- 500: problems getting the video list (bad)

### Get a list of YouTube top viewed videos in the global world

`POST /top_videos/global/{category_id}`

Status

- 200: video list returned (happy)
- 404: invalid category_id (sad)
- 500: problems getting the video list (bad)

### Get a list of YouTube top viewed videos within a continent

`POST /top_videos/continent/{continent_name}/{category_id}`

Status

- 200: video list returned (happy)
- 404: invalid continent_name or category_id (sad)
- 500: problems getting the video list (bad)

### Get a list of YouTube top viewed videos in a country(with it's region code)

`POST /top_videos/continent/{region_code}/{category_id}`

Status

- 200: video list returned (happy)
- 404: invalid region_code or category_id (sad)
- 500: problems getting the video list (bad)


### Add a video to your favoite list

`POST /favorite_videos?PARAMS`

where the `PARAMS` consists of `origin_id={}&title={}&channel_title={}&view_count={}&embed_link={}`, which are from AJAX calling when you click the LIKE icon.

Status

- 201: video stored (happy)
- 404: invalid parameters (sad)
- 500: problems storing the video (bad)

### Delete a video from your favoite list

`DELETE /favorite_videos?origin_id={}`

where the `origin_id` is from the video on which you click the TRASH icon.

Status

- 201: video deleted (happy)
- 404: invalid `origin_id` (sad)
- 500: problems deleting the video (bad)

### Get your favoite list (if you have added any videos)

`GET /favorite_videos`

Status

- 200: video list returned (happy)
- 500: problems getting the video list (bad)

## Acknowledgement
This project is the term project of the Service Oriented Architecture (SOA) lecture in NTHU, lectured by professor [Soumya Ray](https://soumyaray.com/).
We thank for his excellent lectures, valuable feedback and helpful discussions.
