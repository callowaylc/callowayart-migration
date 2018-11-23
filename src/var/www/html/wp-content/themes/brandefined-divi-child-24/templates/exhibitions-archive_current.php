<?php

// WP_Query arguments
$args = array (
	'post_type'  => array( 'exhibitions' ),
	'orderby' => 'post_date',
	'posts_per_page' => 1,
 	'tax_query' => [[
    'taxonomy' => 'exhibition-category',
    'field'    => 'slug',
    'terms'    => ['current-exhibitions'],
	]],
);

// The Query
$query = new WP_Query( $args );

// The Loop
if ( $query->have_posts() ) {
	$query->the_post();
	get_template_part( 'templates/exhibitions', 'archive_current_view' );
}

// Restore original Post Data
wp_reset_query();
wp_reset_postdata();
