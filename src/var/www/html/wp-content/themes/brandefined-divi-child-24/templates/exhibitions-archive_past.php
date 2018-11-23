<?php
$exhibitions = 0;

$args = array (
	'post_type'  => array( 'exhibitions' ),
  'meta_key' => 'exhibition_opening_date',
	'orderby' => 'meta_value',
	'order' => 'DESC',
 	'tax_query' => [[
    'taxonomy' => 'exhibition-category',
    'field'    => 'slug',
    'terms'    => ['past-exhibitions'],
	]]
);

$query = new WP_Query( $args ); ?>

<div class="exhibitions">
			<h3 class="main-heading">Past Exhibitions</h3>
			<div class="bd-flex-grid">
				<!--<div class="past-exhibitions bd-row">-->
<?php

while ( $query->have_posts() ) {
	$query->the_post();
	get_template_part( 'templates/exhibitions', 'archive_past_view' );
}

// Restore original Post Data
wp_reset_postdata();
wp_reset_query();
?>

<!--</div>-->
			</div>
		</div>
