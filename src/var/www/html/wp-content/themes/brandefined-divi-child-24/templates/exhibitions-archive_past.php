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
    'terms'    => ['upcoming-exhibitions', 'current-exhibitions'],
    'operator' => 'NOT IN',
	]]
);

$query = new WP_Query( $args ); ?>

<div class="exhibitions">
			<h3 class="main-heading">Past Exhibitions</h3>
			<div class="bd-flex-grid">
				<!--<div class="past-exhibitions bd-row">-->
<?php

if ( $query->have_posts() ):
	while ( $query->have_posts() ):
		$query->the_post();

		// check for current exhibitions
		$cat_tax = 'exhibition-category';
		$is_past = has_term('past-exhibitions', $cat_tax);

		// diplay past exhibitions if available
		if(true) : ?>

		<?php  if(true) : ?>
			<?php get_template_part( 'templates/exhibitions', 'archive_past_view' ); ?>
		<?php $exhibitions = $exhibitions+1; endif?>

 <?php endif;

	endwhile; // post query
else:

endif;

// Restore original Post Data
wp_reset_postdata();
wp_reset_query();
?>
<!--</div>-->
			</div>
		</div>
