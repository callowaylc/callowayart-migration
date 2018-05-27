<?php

	/* Template Name: Category  */

	get_header();

    $slug = get_queried_object()->post_name;
?>

<div id="main-content">
		<article>
			<div class="entry-content container">
				<h1 class="entry-title main_title"><?php single_cat_title(); ?></h1>
				<div id="artists-by-category" class="bd-grid">
					<?php
						// WP_Query arguments
						$args = array (
							'post_type'			=> 'works',
							'category_name'		=> single_cat_title( '', false ),
							'orderby'   => 'title',
        					'order' => 'ASC'
						);

						// The Query
						$query = new WP_Query( $args );

						// The Loop
						if ( $query->have_posts() ) :
							while ( $query->have_posts() ) :
								$query->the_post();
								if (preg_match("/^private/i", the_title("", "", false))) {
									continue;
								}
								$image = get_the_post_thumbnail($post_id, 'thumbnail');
						?>
								<div class="bd-col col-1-4">
									<?php echo $image; ?>
									<a href="<?php the_permalink($post_id); ?>">
										<span><?php echo the_title(); ?></span>
									</a>
								</div>

					<?php	endwhile;
						endif;
						wp_reset_postdata();
						wp_reset_query();
					?>

				</div><!-- .bd-grid -->
			</div> <!-- .entry-content -->
		</article> <!-- .et_pb_post -->
</div> <!-- #main-content -->
<?php get_footer(); ?>