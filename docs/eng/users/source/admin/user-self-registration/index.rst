.. _user_self_registration:

User Self-Registration Functions
================================

To enable the self-registration functions, see the 'Basic Administration' section of this manual. When self-registration is enabled, the banner menu functions shown to a user who has not logged in should contain two additional choices: 'Forgot your password?' and 'Register' as follows:

.. figure:: usr-banner-functions.png

If 'Register' is chosen the user will be asked to fill out a form as follows:

.. figure:: usr-self-registration-form.png

The fields in this form are self-explanatory except for the following: 

*Email*: The user's email address. This is mandatory and will be used as the username.

*Profile*: By default, self-registered users are given the 'Registered User' 
profile (see previous section). If any other profile is selected: 

- the user will still be given the 'Registered User' profile
- an email will be sent to the Email address nominated in the Feedback section of the 'System Administration' menu, informing them of the request for a more privileged profile


What happens when a user self-registers?
----------------------------------------

When a user self-registration occurs, the user receives an email with the
details they have provided in it that looks something like the following:

::

	Dear User,

	  Your registration at The Greenhouse GeoNetwork Site was successful.
 
	  Your account is:
	  username :    dubya.shrub@greenhouse.gov
	  password :    0110O3
	  usergroup:    GUEST
	  usertype :    REGISTEREDUSER

	  You've told us that you want to be "Editor", you will be contacted by our office soon.

	  To log in and access your account, please click on the link below.
	  http://greenhouse.gov/geonetwork

	  Thanks for your registration.

		Yours sincerely,
		The team at The Greenhouse GeoNetwork Site

Notice that the user has requested an 'Editor' profile. As a result an email will be sent to the Email address nominated in the Feedback section of the 'System Adminstration' menu which looks something like the following:

Notice also that the user has been aded to the built-in user group 'GUEST'. This is a security restriction. An administrator/user-administrator can add the user to other groups if that is required later.

If you want to change the content of this email, you should modify INSTALL_DIR/web/geonetwork/xsl/registration-pwd-email.xsl.

::

	Dear Admin,     

		Newly registered user dubya.shrub@greenhouse.gov has requested "Editor" access for:

		Instance:     The Greenhouse GeoNetwork Site
		Url:          http://greenhouse.gov/geonetwork

		User registration details:
 
 		Name:         Dubya
 		Surname:      Shrub
 		Email:        dubya.shrub@greenhouse.gov
 		Organisation: The Greenhouse
 		Type:         gov
 		Address:      146 Main Avenue, Creationville
 		State:        Clerical
 		Post Code:    92373 
 		Country:      Mythical

 	Please action.

	The Greenhouse GeoNetwork Site

If you want to change the content of this email, you should modify INSTALL_DIR/web/geonetwork/xsl/registration-prof-email.xsl.

The 'Forgot your password?' function
------------------------------------

This function allows users who have forgotten their password to request a new one. For security reasons, only users that have the 'Registered User' profile can request a new password.


