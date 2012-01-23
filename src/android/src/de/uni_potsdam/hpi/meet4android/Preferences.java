package de.uni_potsdam.hpi.meet4android;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;

public class Preferences {

    private SharedPreferences pref;

    public Preferences(Activity activity) {
        pref = activity.getSharedPreferences("meet4xmas", Context.MODE_PRIVATE);
    }

    public void setUser(final String name) {
        editorDo(new Change() {
            public void edit(SharedPreferences.Editor editor) {
                editor.putString("user", name);
            }
        });
    }

    public String getUser() {
        return pref.getString("user", null);
    }

    private void editorDo(Change change) {
        SharedPreferences.Editor editor = pref.edit();
        change.edit(editor);
        editor.commit();
    }

    interface Change {
        public void edit(SharedPreferences.Editor editor);
    }
}
