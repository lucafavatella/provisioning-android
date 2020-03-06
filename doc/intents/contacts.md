# Contacts

## Specifications

### `android.provider.ContactsContract`

From https://developer.android.com/reference/android/provider/ContactsContract :

> ## Overview
>
> ContactsContract defines an extensible database of contact-related information. Contact information is stored in a three-tier data model:
> - A row in the [`Data`](https://developer.android.com/reference/android/provider/ContactsContract.Data) table can store any kind of personal data ...
> - A row in the [`RawContacts`](https://developer.android.com/reference/android/provider/ContactsContract.RawContacts) table represents a set of data describing a person and associated with a single account ...
> - A row in the [`Contacts`](https://developer.android.com/reference/android/provider/ContactsContract.Contacts) table represents an aggregate of one or more RawContacts presumably describing the same person. ...
>
> ## Summary
>
> ### Nested classes
>
> class `ContactsContract.Intents`
>
> Contains helper classes used to create or manage `Intents` that involve contacts.

From https://developer.android.com/reference/android/provider/ContactsContract.Intents :

> ## Summary
>
> ### Nested classes
>
> class `ContactsContract.Intents.Insert`
>
> Convenience class that contains string constants used to create contact Intents.

From https://developer.android.com/reference/android/provider/ContactsContract.Intents.Insert :

> ## Constants
>
> ### NAME
>
> The extra field for the contact name.
>
> Type: String
>
> Constant Value: "name"
>
> ### NOTES
>
> The extra field for the contact notes.
>
> Type: String
>
> Constant Value: "notes"
>
> ### PHONE
>
> The extra field for the contact phone number.
>
> Type: String
>
> Constant Value: "phone"

#### `vnd.android.cursor.item/contact` and `vnd.android.cursor.dir/contact`

From https://developer.android.com/reference/android/provider/ContactsContract.Contacts :

> ## Operations
>
> ### Insert
>
> A Contact cannot be created explicitly. When a raw contact is inserted, the provider will first try to find a Contact representing the same person. If one is found, the raw contact's `RawContacts#CONTACT_ID` column gets the _ID of the aggregate Contact. If no match is found, the provider automatically inserts a new Contact and puts its _ID into the `RawContacts#CONTACT_ID` column of the newly inserted raw contact.
>
> ## Constants
>
> ### CONTENT_ITEM_TYPE
>
> The MIME type of a `CONTENT_URI` subdirectory of a single person.
>
> Constant Value: "vnd.android.cursor.item/contact"
>
> ### CONTENT_TYPE
>
> The MIME type of `CONTENT_URI` providing a directory of people.
>
> Constant Value: "vnd.android.cursor.dir/contact"

#### `vnd.android.cursor.item/raw_contact` and `vnd.android.cursor.dir/raw_contact`

From https://developer.android.com/reference/android/provider/ContactsContract.RawContacts :

> ## Operations
>
> ### Insert
>
> Raw contacts can be inserted incrementally or in a batch. The incremental method is more traditional but less efficient. It should be used only if no `Data` values are available at the time the raw contact is created ...
>
> ## Columns
>
> |   |   |   |   |
> | - | - | - | - |
> | String | `ContactsContract.SyncColumns.ACCOUNT_NAME` | read/write-once | The name of the account instance to which this row belongs, which when paired with `ContactsContract.SyncColumns.ACCOUNT_TYPE` identifies a specific account. For example, this will be the Gmail address if it is a Google account. It should be set at the time the raw contact is inserted and never changed afterwards. |
> | String | `ContactsContract.SyncColumns.ACCOUNT_TYPE` | read/write-once | The type of account to which this row belongs, which when paired with ContactsContract.SyncColumns.ACCOUNT_NAME identifies a specific account.  To ensure uniqueness, new account types should be chosen according to the Java package naming convention. Thus a Google account is of type "com.google". |
>
> ## Constants
>
> ### CONTENT_ITEM_TYPE
>
> The MIME type of the results when a raw contact ID is appended to `CONTENT_URI`, yielding a subdirectory of a single person.
>
> Constant Value: "vnd.android.cursor.item/raw_contact"
>
> ### CONTENT_TYPE
>
> The MIME type of the results from `CONTENT_URI` when a specific ID value is not provided, and multiple raw contacts may be returned.
>
> Constant Value: "vnd.android.cursor.dir/raw_contact"
>
> ## Public methods
>
> ### `getLocalAccountName`	Added in Android R
>
> The default value used for `ContactsContract.SyncColumns.ACCOUNT_NAME` of raw contacts when they are inserted without a value for this column.
>
> This account is used to identify contacts that are only stored locally in the contacts database instead of being associated with an Account managed by an installed application.
>
> ### `getLocalAccountType`	Added in Android R
>
> The default value used for `ContactsContract.SyncColumns.ACCOUNT_TYPE` of raw contacts when they are inserted without a value for this column.
>
> This account is used to identify contacts that are only stored locally in the contacts database instead of being associated with an Account managed by an installed application.
