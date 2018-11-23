<div class="exhibitions upcoming">

	<h2 class="main-heading">Upcoming Exhibitions</h2>
	<?php
	// WP_Query arguments
	$args = array (
		'post_type'  => array( 'exhibitions' ),
		'orderby' => 'post_date',
		'posts_per_page' => 2,
   	'tax_query' => [[
      'taxonomy' => 'exhibition-category',
      'field'    => 'slug',
      'terms'    => ['upcoming-exhibitions'],
		]]
	);

	// The Query
	$query = new WP_Query( $args );

	// The Loop
	if ( $query->have_posts() ):
		while ( $query->have_posts() ):
			$query->the_post();

			// check for current exhibitions
			$cat_tax = 'exhibition-category';
			$is_upcoming = has_term('upcoming-exhibitions', $cat_tax);

			// diplay upcoming exhibitions if available
			if($is_upcoming) : ?>

				<div class="bd-grid">
					<div class="upcoming-exhibitions bd-row">
						<?php get_template_part( 'templates/exhibitions', 'archive_upcoming_view' ); ?>
					</div>
				</div>
	 <?php endif;

		endwhile; // post query
	else:

	endif;

	// Restore original Post Data
	wp_reset_postdata();
	wp_reset_query(); ?>
</div>