<div class="exhibitions upcoming">
	<h2 class="main-heading">Upcoming Exhibitions</h2>

<?php
	// WP_Query arguments
	$args = array (
		'post_type'  => array( 'exhibitions' ),
		'orderby' => 'post_date',
   	'tax_query' => [[
      'taxonomy' => 'exhibition-category',
      'field'    => 'slug',
      'terms'    => ['upcoming-exhibitions'],
		]]
	);
	$query = new WP_Query( $args );

	if ( $query->have_posts() ) {
		while ( $query->have_posts() ) {
			$query->the_post();
?>
				<div class="bd-grid">
					<div class="upcoming-exhibitions bd-row">
						<?php
							get_template_part( 'templates/exhibitions', 'archive_upcoming_view' );
						?>
					</div>
				</div>
<?php
		}
	}

	// Restore original Post Data
	wp_reset_postdata();
	wp_reset_query();
?>

</div>
