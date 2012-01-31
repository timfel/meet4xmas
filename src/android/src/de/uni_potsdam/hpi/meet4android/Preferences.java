package de.uni_potsdam.hpi.meet4android;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;

public class Preferences {

    private SharedPreferences pref;

    public Preferences(Context context) {
        pref = context.getSharedPreferences("meet4xmas", Context.MODE_PRIVATE);
    }

    public void setUser(final String name) {
        editorDo(new Change() {
            public void edit(SharedPreferences.Editor editor) {
                if (name == null) {
                    editor.remove("user");
                } else {
                    editor.putString("user", name);
                }
            }
        });
    }

    public boolean isUser() {
        return pref.contains("user");
    }

    public String getUser() {
        return pref.getString("user", null);
    }

    public void setRegistrationId(final String id) {
        editorDo(new Change() {
            public void edit(SharedPreferences.Editor editor) {
                if (id == null) {
                    editor.remove("registration_id");
                } else {
                    editor.putString("registration_id", id);
                }
            }
        });
    }

    public boolean isRegistrationId() {
        return pref.contains("registration_id");
    }

    public String getRegistrationId() {
        return pref.getString("registration_id", null);
    }

    private void editorDo(Change change) {
        SharedPreferences.Editor editor = pref.edit();
        change.edit(editor);
        editor.commit();
    }

    static interface Change {
        public void edit(SharedPreferences.Editor editor);
    }
}
