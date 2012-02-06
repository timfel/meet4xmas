package de.uni_potsdam.hpi.meet4android;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;

public class MessageBox {

    private AlertDialog dialog;

    public MessageBox(String message, Context context) {
        AlertDialog.Builder dialog = new AlertDialog.Builder(context);
        dialog.setMessage(message);
        dialog.setPositiveButton("ok", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialogInterface, int i) { }
        });
        this.dialog = dialog.create();
    }

    public void show() {
        dialog.show();
    }

    public AlertDialog getDialog() {
        return dialog;
    }
}
