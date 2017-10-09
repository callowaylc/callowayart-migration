<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

ini_set('display_errors', 1);
error_reporting(E_ALL & ~E_NOTICE);

define( 'WP_MEMORY_LIMIT', '512M' );

define( 'DBI_AWS_ACCESS_KEY_ID', $_ENV["MIGRATION_AWS_ACCESS_KEY_ID"] );
define( 'DBI_AWS_SECRET_ACCESS_KEY', $_ENV["MIGRATION_SECRET_ACCESS_KEY"] );

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'wordpress');

/** MySQL database username */
define('DB_USER', 'wordpress');

/** MySQL database password */
define('DB_PASSWORD', 'wordpress');

/** MySQL hostname */
define('DB_HOST', 'db:3306');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8mb4');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');
define('FS_METHOD', 'direct');
/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         '&$cq-zlSC=)hRz,Y>,)p8{?* -u6_fOVNg.J-<o@6B%,msRjXG$>4*J|w@$MF&zE');
define('SECURE_AUTH_KEY',  '[u,B)VLd,~hHcGP>lNd9=j=, QA?k5h-LtGm:Cm,P5simXJZAM&=&w<<]w+U]]Z(');
define('LOGGED_IN_KEY',    '42]1>8XJ|n9Y|xy|s3r}S uc-Gw-%C>Ki.-gcA-I8IEHFax3r?:M2iV%-WBf36}f');
define('NONCE_KEY',        'VdBZ0!p,q60CLRhE%e+DUSqf!-4wARVKy*[plp;N93^n6PTx${<73J>,>tkEr5%H');
define('AUTH_SALT',        'JZ0}2Fbfx@8Q{r/.yDszp@[CVD!61NiI0nkd#otsE  NDw%)kiC-YqD[++3i`8!L');
define('SECURE_AUTH_SALT', '=F^pTTA|mBV+w%78r4AV|1x4KD+[/S,>6J7F< Eu.:D-`g0Ud6}g*T]kcl$[Qp ;');
define('LOGGED_IN_SALT',   '-uYlz*WMWuR,T% 0[l}J[R>G{G;!>Kd  )2PC65s`B|D~wIe4HX=_P;Ds@e.V={r');
define('NONCE_SALT',       'WVv]*vfJV;xX^{SG2#sS%`!weDJsrd,f8HG.LQVs`KrYJwGT3GF|wxz~~(RIo`W@');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
define('WP_DEBUG', false);
define('WP_DEBUG_LOG', false);
define('WP_HOME','http://' . $_SERVER['HTTP_HOST']);
define('WP_SITEURL','http://' . $_SERVER['HTTP_HOST']);
/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
