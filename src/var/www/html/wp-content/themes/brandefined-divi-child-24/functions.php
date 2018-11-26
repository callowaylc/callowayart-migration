<?php
// Enqueue the child theme styles and scripts here, the WordPress way
function theme_enqueue_styles() {
    wp_enqueue_style( 'parent-style', get_template_directory_uri() . '/style.css' );
    wp_enqueue_script( 'divi-child-js', get_stylesheet_directory_uri() . '/js/divi-child.js', array('jquery'), '1.0.0', true );
   	wp_enqueue_script(
        'custom-js',
        get_stylesheet_directory_uri() . '/js/custom.js',
        array(
            'jquery',
            'divi-child-js'
            ), '1.0.0', true );
}
add_action( 'wp_enqueue_scripts', 'theme_enqueue_styles' );

// Extended functionality for the base Brandefined Divi child theme can be found here
include_once("includes/divi-child.php");
include_once("includes/inc.custom-post-types.php");

// Kenny's custom fancifying functions
function setColumns($post_count)
{
    // divisible by 3
    if ($post_count % 3 == 0) {
        $cols = 'bd-flex-col-1-3';
    }
    // divisible by 4
    if ($post_count % 4 == 0) {
        $cols = 'bd-flex-col-1-4';
    }
    // divisible by 5
    if ($post_count % 5 == 0) {
        $cols = 'bd-flex-col-1-5';
    }
    echo $cols;
}

// Used for making pretty date ranges
function dateSuffix($input_date)
{
    switch ($input_date) {
        case '1':
        case '21':
        case '31':
            $suffix = 'st';
            break;
        case '2':
        case '22':
            $suffix = 'nd';
            break;
        case '3':
        case '23':
            $suffix = 'rd';
            break;
        default:
            $suffix = 'th';
    }
    $output = $input_date . $suffix;
    return $output;
}

// gimme a range of dates
function dateRange($start_date, $end_date)
{
    $start_obj   = new DateTime($start_date);
    $end_obj     = new DateTime($end_date);

    $start_month = $start_obj->format('F');
    $start_day   = $start_obj->format('j');
    $start_year  = $start_obj->format('Y');
    $end_month   = $end_obj->format('F');
    $end_day     = $end_obj->format('j');
    $end_year    = $end_obj->format('Y');
    $start_date  = $start_month . " " . dateSuffix($start_day) . " " . $start_year . " - ";
    $end_date    = $end_month . " " . dateSuffix($end_day) . " " . $end_year;
    $date_range  = $start_date . $end_date;

    return $date_range;
}

// Remove post types we dont need.
if (!function_exists('remove_unused_posttypes')) {
    function remove_unused_posttypes()
    {
        global $wp_post_types;
        $postIds = array(
            'project',
            'post',
            'essential_grid'
        );
        foreach ($postIds as $cpt) {
            if (isset($wp_post_types[$cpt])) {
                unset($wp_post_types[$cpt]);
            }
        }
        return false;
    }
    add_action('init', 'remove_unused_posttypes', 100);
}

// Customize our category meta box for the works custom post type
function bd_works_categories_meta_box( $post, $box )
{
    $defaults = array( 'taxonomy' => 'category' );

    if ( !isset( $box['args'] ) || !is_array( $box['args'] ) )
    {
        $args = array();
    }
    else
    {
        $args = $box['args'];
    }

    $r = wp_parse_args( $args, $defaults );
    $tax_name = esc_attr( $r['taxonomy'] );
    $taxonomy = get_taxonomy( $r['taxonomy'] ); ?>

    <div id="taxonomy-<?php echo $tax_name; ?>" class="categorydiv">
        <ul id="<?php echo $tax_name; ?>-tabs" class="category-tabs">
            <li class="tabs"><a href="#<?php echo $tax_name; ?>-all">Categories</a></li>
        </ul>

        <div id="<?php echo $tax_name; ?>-all" class="tabs-panel">
            <?php
            $name = ( $tax_name == 'category' ) ? 'post_category' : 'tax_input[' . $tax_name . ']';
            echo "<input type='hidden' name='{$name}[]' value='0' />"; ?>
            <ul id="<?php echo $tax_name; ?>checklist" data-wp-lists="list:<?php echo $tax_name; ?>" class="categorychecklist form-no-clear">
                <?php wp_terms_checklist( $post->ID, array( 'taxonomy' => $tax_name, 'popular_cats' => $popular_ids ) ); ?>
            </ul>
        </div>
    </div>
<?php
}

// Rename meta boxes for cpts
function bd_works_meta_boxes(){
    remove_meta_box('postimagediv', 'works', 'side');
    remove_meta_box('categorydiv', 'artist', 'side');
    add_meta_box('postimagediv', __('Work Image'), 'post_thumbnail_meta_box', 'works', 'normal', 'high');
    add_meta_box('categorydiv', __('Category'), 'bd_works_categories_meta_box', 'artist', 'normal', 'high');
}
add_action('do_meta_boxes', 'bd_works_meta_boxes');

// Rename more meta boxes
function bd_artist_image_box()
{
    remove_meta_box('postimagediv', 'artist', 'side');
    add_meta_box('postimagediv', __('Featured Image'), 'post_thumbnail_meta_box', 'artist', 'normal', 'high');
}
add_action('do_meta_boxes', 'bd_artist_image_box');


// enables divi builder on selected custom post types
function custom_post_types() {
    $cpts = array(
        'artist'
    );
    return $cpts;
}

function bd_add_post_types($post_types) {
    foreach (custom_post_types() as $pt) {
        if (!in_array($pt, $post_types) and post_type_supports($pt, 'editor')) {
            $post_types[] = $pt;
        }
    }
    return $post_types;
}
add_filter('et_builder_post_types', 'bd_add_post_types');

function bd_add_meta_boxes() {
    foreach (custom_post_types() as $pt) {
        if (post_type_supports($pt, 'editor') and function_exists('et_single_settings_meta_box')) {
            add_meta_box('et_settings_meta_box', __('Divi Custom Post Settings', 'Divi'), 'et_single_settings_meta_box', $pt, 'side', 'high');
        }
    }
}
add_action('add_meta_boxes', 'bd_add_meta_boxes');

function bd_admin_js()  {
    $s = get_current_screen();
    if(!empty($s->post_type) and $s->post_type!='page' and $s->post_type!='post') : ?>
        <script>jQuery(function($){ $('#et_pb_layout').insertAfter($('#et_pb_main_editor_wrap')); });</script>
        <style>#et_pb_layout { margin-top:20px; margin-bottom:0px } </style> <?php
    endif;
}
add_action('admin_head', 'bd_admin_js');

/** WORKS CUSTOM POST TYPE SPECIFIC */
function add_blog_automatically($post_ID) {
    global $wpdb;
    global $current_user;
    if (!has_term('', 'work-category', $post_ID)) {
        $cat = 'all';
        wp_set_object_terms($post_ID, $cat, 'work-category');
    }
}
add_action('publish_works', 'add_blog_automatically');

function brandefined_edit_works_columns($columns) {
    $columns = array(
        'cb' => '<input type="checkbox" />',
        'title' => __('Work'),
        'artist' => __('Artist'),
        'date' => __('Date')
    );
    return $columns;
}
add_filter('manage_edit-works_columns', 'brandefined_edit_works_columns');

function brandefined_manage_works_columns($column, $post_id) {
    global $post;
    switch ($column) {
        case 'artist':
            $the_post = get_field('works-artist');
            echo $the_post->post_title;
            break;
        default:
            break;
    }
}
add_action('manage_works_posts_custom_column', 'brandefined_manage_works_columns', 10, 2);


/** add sorting capability to "category" column for exhibition categories in dashboard **/
if (!function_exists('brandefined_update_custom_column') && !function_exists('brandefined_custom_column_sort')) {
    function brandefined_update_custom_column($columns)
    {
        $columnSlug = 'taxonomy-exhibition-category';

        $columns[$columnSlug] = $columnSlug;
        return $columns;
    }
    add_filter('manage_edit-exhibitions_sortable_columns', 'brandefined_update_custom_column');

    function brandefined_custom_column_sort($sql_clause, $wp_query)
    {
        global $wpdb;

        $columnSlug = 'taxonomy-exhibition-category';
        $taxonomy   = 'exhibition-category';
        $postType   = 'exhibitions';

        if (isset($wp_query->query['orderby']) && $wp_query->query['orderby'] == $columnSlug)
        {
            $sql_clause['join'] .= <<<SQL
            LEFT OUTER JOIN {$wpdb->term_relationships} ON {$wpdb->posts}.ID={$wpdb->term_relationships}.object_id
LEFT OUTER JOIN {$wpdb->term_taxonomy} USING (term_taxonomy_id)
LEFT OUTER JOIN {$wpdb->terms} USING (term_id)
SQL;
            $sql_clause['where'] .= "AND (taxonomy = '" . $taxonomy . "' OR taxonomy IS NULL)";
            $sql_clause['groupby'] = "object_id";
            $sql_clause['orderby'] = "GROUP_CONCAT({$wpdb->terms}.name ORDER BY name ASC)";
            if (strtoupper($wp_query->get('order')) == 'ASC')
            {
                $sql_clause['orderby'] .= 'ASC';
            }
            else
            {
                $sql_clause['orderby'] .= 'DESC';
            }
        }
        return $sql_clause;
    }
    add_filter('posts_clauses', 'brandefined_custom_column_sort', 10, 2);
}


// don't hate, appreciate, I know it has some specific coded shiz, just deal with it.
function get_random_image($atts) {
    $default_post_type = (post_type_exists('works')) ? 'works' : '';

    extract(shortcode_atts(array(
        'posts' => 1,
        'cat' => '',
        'post_type' => $default_post_type
    ), $atts));

    query_posts(
        array(
            'post_type'             => $post_type,
            'orderby'               => 'rand',
            'ignore_sticky_posts'   => 1,
            'category_name'         => $cat,
            'posts_per_page'        => $posts
        )
    );

    if (have_posts()) :
        while (have_posts()) : the_post();
            if ( has_post_thumbnail() ) :
                $artist = get_field('works-artist');
                if( $artist ):

                    $post = $artist;
                    setup_postdata( $post );

                    $artist_name = get_the_title( $post );
                    wp_reset_postdata();

                endif;
                $thumb_id = get_post_thumbnail_id();
                $thumb_url = wp_get_attachment_image_src($thumb_id,'full', true);
                $output = '<a class="home-page-mobile-link" href="' . get_the_permalink() . '">'.
                          '  <div class="home-page-mobile-image">' .
                          '  <div class="home-page-mobile-overlay">' .
                          '    <div class="title">' . get_the_title() . '</div>' .
                          '    <div class="artist">by ' . $artist_name . '</div>' .
                          '  </div>' .

                          '    <img style="width: 100%;height:auto" src="' . $thumb_url[0] . '"/>' .
                          '  </div>' .
                          '</a>';
            endif;
        endwhile;
    endif;

    wp_reset_query();

    return $output;
}

function register_shortcodes(){
    add_shortcode('random-image', 'get_random_image');
}
add_action( 'init', 'register_shortcodes');

/* Placeholder images */
add_filter( 'post_thumbnail_html', 'wpse_63591_default_thumb' );
function wpse_63591_default_thumb( $html ){
    if ( '' !== $html ) {
        return '<a href="' . get_permalink() . '">' . $html . '</a>'; }
    return '<img src="http://via.placeholder.com/350x350" />';
}

add_filter( 'redirect_canonical', 'custom_disable_redirect_canonical' );
function custom_disable_redirect_canonical( $redirect_url ) {
    if ( is_paged() && is_singular() ) $redirect_url = false;
    return $redirect_url;
}
/**
* auto_child_page_menu
*
* class to add top level page menu items all child pages on the fly
* @author Ohad Raz <admin@bainternet.info>

class auto_child_page_menu
{
    /**
     * class constructor
     * @author Ohad Raz <admin@bainternet.info>
     * @param   array $args
     * @return  void

    function __construct($args = array()){
        add_filter('wp_nav_menu_objects',array($this,'on_the_fly'));
    }
    /**
     * the magic function that adds the child pages
     * @author Ohad Raz <admin@bainternet.info>
     * @param  array $items
     * @return array

    function on_the_fly($items) {
        global $post;
        $tmp = array();
        foreach ($items as $key => $i) {
            $tmp[] = $i;
            //if not page move on
            if ($i->object != 'page'){
                continue;
            }
            $page = get_post($i->object_id);
            //if not parent page move on
            if (!isset($page->post_parent) || $page->post_parent != 0) {
                continue;
            }
            $children = get_pages( array('child_of' => $i->object_id) );
            foreach ((array)$children as $c) {
                //set parent menu
                $c->menu_item_parent      = $i->ID;
                $c->object_id             = $c->ID;
                $c->object                = 'page';
                $c->type                  = 'post_type';
                $c->type_label            = 'Page';
                $c->url                   = get_permalink( $c->ID);
                $c->title                 = $c->post_title;
                $c->target                = '';
                $c->attr_title            = '';
                $c->description           = '';
                $c->classes               = array('','menu-item','menu-item-type-post_type','menu-item-object-page');
                $c->xfn                   = '';
                $c->current               = ($post->ID == $c->ID)? true: false;
                $c->current_item_ancestor = ($post->ID == $c->post_parent)? true: false; //probbably not right
                $c->current_item_parent   = ($post->ID == $c->post_parent)? true: false;
                $tmp[] = $c;
            }
        }
        return $tmp;
    }
}
new auto_child_page_menu()
************/


function wpd_subcategory_template( $template ) {
    $cat = get_queried_object();
    if( 0 < $cat->category_parent )
        $template = locate_template( 'subcategory.php' );
    return $template;
}
add_filter( 'category_template', 'wpd_subcategory_template' );


add_action('init', function() {
    global $wp_rewrite;
    $wp_rewrite->set_permalink_structure('/%postname%');
});
