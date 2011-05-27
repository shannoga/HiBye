/*
 *  SCTableViewDefs.h
 *  Sensible TableView
 *
 *
 *	THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY UNITED STATES 
 *	INTELLECTUAL PROPERTY LAW AND INTERNATIONAL TREATIES. UNAUTHORIZED REPRODUCTION OR 
 *	DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES. YOU SHALL NOT DEVELOP NOR
 *	MAKE AVAILABLE ANY WORK THAT COMPETES WITH A SENSIBLE COCOA PRODUCT DERIVED FROM THIS 
 *	SOURCE CODE. THIS SOURCE CODE MAY NOT BE RESOLD OR REDISTRIBUTED ON A STAND ALONE BASIS.
 *
 *	USAGE OF THIS SOURCE CODE IS BOUND BY THE LICENSE AGREEMENT PROVIDED WITH THE 
 *	DOWNLOADED PRODUCT.
 *
 *  Copyright 2010 Sensible Cocoa. All rights reserved.
 *
 *
 *	This notice may not be removed from this file.
 *
 */


/*! The types of navigation bars used in SCViewController and SCTableViewController. */
typedef enum
{
	/*! Navigation bar with no buttons. */
	SCNavigationBarTypeNone,
	/*! Navigation bar with an Add button on the left. */
	SCNavigationBarTypeAddLeft,
	/*! Navigation bar with an Add button on the right. */
	SCNavigationBarTypeAddRight,
	/*! Navigation bar with an Edit button on the left. */
	SCNavigationBarTypeEditLeft,
	/*! Navigation bar with an Edit button on the right. */
	SCNavigationBarTypeEditRight,
	/*! Navigation bar with an Add button on the right and an Edit button on the left. */
	SCNavigationBarTypeAddRightEditLeft,
	/*! Navigation bar with an Add button on the left and an Edit button on the right. */
	SCNavigationBarTypeAddLeftEditRight,
	/*! Navigation bar with a Done button on the left. */
	SCNavigationBarTypeDoneLeft,
	/*! Navigation bar with a Done button on the right. */
	SCNavigationBarTypeDoneRight,
	/*! Navigation bar with a Done button on the left and a Cancel button on the right. */
	SCNavigationBarTypeDoneLeftCancelRight,
	/*! Navigation bar with a Done button on the right and a Cancel button on the left. */
	SCNavigationBarTypeDoneRightCancelLeft,
	/*! Navigation bar with both an Add and Edit buttons on the right. */
	SCNavigationBarTypeAddEditRight
	
} SCNavigationBarType;
