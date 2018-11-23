<?php

// WP_Query arguments
$args = array (
	'post_type'  => array( 'exhibitions' ),
	'orderby' => 'post_date',
	'posts_per_page' => 1,
);

// The Query
$query = new WP_Query( $args );

// The Loop
if ( $query->have_posts() ):
	while ( $query->have_posts() ):
		$query->the_post();

		// check for current exhibitions
		$cat_tax = 'exhibition-category';
		$is_current = has_term('current-exhibitions', $cat_tax);

		// diplay current exhibition if available
		if($is_current) :
			get_template_part( 'templates/exhibitions', 'archive_current_view' );
 		endif;

	endwhile; // post query
else:

endif;

// Restore original Post Data
wp_reset_query();
wp_reset_postdata(); ?>


