use inc::Module::Install;

name('Bancuri');
abstract('Catalyst Application');
author('vio,,,');
version_from('lib/Bancuri.pm');
license('perl');

include('ExtUtils::AutoInstall');

requires( Catalyst => '5.60' );

catalyst_files();

install_script( glob('script/*.pl') );
auto_install();
&WriteAll;
