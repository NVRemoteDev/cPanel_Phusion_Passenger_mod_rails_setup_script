cPanel 11.3 Phusion Passenger / Mod_Rails Setup Script
===============================================

A bash script to correctly configure rails apps, cPanel, and Apache/Phusion Passenger for web environment (easy)

Requirements: 
-- cPanel 11.3x (maybe other versions let me know)
-- Phusion Passenger
-- Rails installed (tested with rails 3.2.8)
-- Ruby installed (tested with ruby 1.9.3p327 (2012-11-10 revision 37606) [i686-linux])

NOTE: You can use RVM to install the lastest Ruby and Rails on a cPanel server.  I will be writing a tutorial on how to do this shortly.

Instructions:
-- Create a Rails app if you have not already (Recommend putting your app in /home/username/$yourappname)
-- Enter 'sh ./rubypermissions.sh' in the shell
-- Enter your cPanel login name
-- Enter the domain that will access the Ruby on Rails application
-- Enter the URL PATH NAME that will be used to access the application (i.e.: if you you want to access your rails application through http://mydomain.com/myrails then enter myrails, leave blank for the whole domain as a rails app)
-- That's it! Let the script do its thing.

NOTE: THERE IS NO ERROR CHECKING AT THIS TIME.  DOUBLE CHECK YOUR INPUTS FOR TYPOS.

If you run into any problems you can contact me at hill dot anthony @ live d0t com