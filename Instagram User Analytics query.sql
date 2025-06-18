
USE ig_clone;

# Identify the five oldest users on Instagram

SELECT * FROM users
ORDER BY created_at ASC
LIMIT 5;

# Identify users who have never posted a single photo on Instagram

SELECT users.*, image_url FROM users
LEFT JOIN photos
ON users.id = photos.user_id
WHERE image_url IS NULL;

# another way to make it visually appealing

SELECT users.*, 'No photos' AS image_status
FROM users
LEFT JOIN photos ON users.id = photos.user_id
WHERE photos.image_url IS NULL;

# Determine the user with the most likes on a single photo

SELECT 
    photos.user_id, most_likes.*, users.username
FROM
    users
        INNER JOIN
    photos ON users.id = photos.user_id
        INNER JOIN
    (SELECT 
        photo_id, COUNT(user_id) AS like_count
    FROM
        likes
    GROUP BY photo_id
    ORDER BY like_count DESC
    LIMIT 1) AS most_likes ON photos.id = most_likes.photo_id;

# Identify the top five most commonly used hashtags

SELECT 
    top_5.tag_count, tags.tag_name AS top_5_hashtags
FROM
    tags
        INNER JOIN
    (SELECT 
        tag_id, COUNT(tag_id) AS tag_count
    FROM
        photo_tags
    GROUP BY tag_id
    ORDER BY tag_count DESC
    LIMIT 5) AS top_5 ON tags.id = top_5.tag_id;

# Determine the day of the week when most users register on Instagram

SELECT 
    DAYNAME(created_at) AS day_registered,
    COUNT(username) AS user_count
FROM
    users
GROUP BY day_registered
ORDER BY user_count DESC;

# Calculate the average number of posts per user on Instagram

SELECT 
    AVG(pc.post_count) AS avg_post_count,
    (SELECT 
            COUNT(*)
        FROM
            photos) AS total_photos,
    (SELECT 
            COUNT(*)
        FROM
            users) AS total_users,
    (SELECT total_photos / total_users) AS photos_per_user
FROM
    users
        LEFT JOIN
    (SELECT 
        user_id, COUNT(id) AS post_count
    FROM
        photos
    GROUP BY user_id) AS pc ON users.id = pc.user_id
;

# Identify potential bots

WITH potential_bots AS (SELECT user_id, COUNT(photo_id) AS liked_photos_count
FROM likes
GROUP BY user_id
HAVING liked_photos_count = (SELECT DISTINCT COUNT(*) FROM photos)
)
SELECT id, username, liked_photos_count FROM potential_bots AS pb
INNER JOIN users ON pb.user_id = users.id;