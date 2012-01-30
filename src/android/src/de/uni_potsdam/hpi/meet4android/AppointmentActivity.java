package de.uni_potsdam.hpi.meet4android;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.view.View;
import android.widget.*;
import android.provider.ContactsContract.Contacts;
import org.meet4xmas.Service;
import org.meet4xmas.ServiceException;
import org.meet4xmas.wire.TravelPlan;

import java.util.LinkedList;
import java.util.List;

public class AppointmentActivity extends Activity {

    private AppointmentActivity self = this;
    private ArrayAdapter<String> contacts;
    private static final int CONTACT_PICKER_RESULT = 1001;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.appointment);

        setupListView();
        setupCreateButton();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode == RESULT_OK) {
            switch (requestCode) {
                case CONTACT_PICKER_RESULT:
                    String contactId = data.getData().getLastPathSegment();
                    Cursor cursor = managedQuery(ContactsContract.CommonDataKinds.Email.CONTENT_URI, null,
                            ContactsContract.CommonDataKinds.Email.CONTACT_ID + " = ?",
                            new String[]{contactId}, null);
                    try {
                        if (cursor.moveToNext()) {
                            String email = cursor.getString(cursor.getColumnIndex(
                                    ContactsContract.CommonDataKinds.Email.DATA));
                            contacts.add(email);
                            break;
                        }
                    } finally {
                        cursor.close();
                    }
                default:
                    Toast.makeText(self, self.getText(R.string.appointment_no_email), Toast.LENGTH_LONG).show();
            }
        }
    }

    protected void setupListView() {
        contacts = new ArrayAdapter<String>(this, R.layout.contact_item);

        ListView list = (ListView) findViewById(R.id.who_list);
        View footer = getLayoutInflater().inflate(R.layout.add_contact, null);
        Button add = (Button) footer.findViewById(R.id.add_contact_button);

        list.addFooterView(footer, null, true);
        list.setAdapter(contacts);

        add.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                Intent contactPickerIntent = new Intent(Intent.ACTION_PICK, Contacts.CONTENT_URI);
                startActivityForResult(contactPickerIntent, CONTACT_PICKER_RESULT);
            }
        });

        list.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                final String email = (String) contacts.getItem(position);
                AlertDialog.Builder dialog = new AlertDialog.Builder(self);
                dialog.setMessage(self.getText(R.string.appointment_remove_contact));
                dialog.setPositiveButton(self.getText(R.string.label_yes), new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialogInterface, int i) {
                        contacts.remove(email);
                    }
                });
                dialog.setNegativeButton(self.getText(R.string.label_no), new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialogInterface, int i) { }
                });
                dialog.create().show();
            }
        });
    }

    protected void setupCreateButton() {
        Button button = (Button) findViewById(R.id.create_appointment_button);
        button.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                List<String> emails = new LinkedList<String>();
                for (int i = 0; i < contacts.getCount(); ++i) {
                    emails.add(contacts.getItem(i));
                }
                Service service = new Service(self);
                String user = new Preferences(self).getUser();
                TextView what = (TextView) self.findViewById(R.id.appointment_what);
                try {
                    service.createAppointment(user, what.getText().toString(), emails,
                            TravelPlan.TravelType.PublicTransport);
                } catch (ServiceException e) {
                    Toast.makeText(self, e.getMessage(), Toast.LENGTH_LONG).show();
                }
            }
        });
    }
}
