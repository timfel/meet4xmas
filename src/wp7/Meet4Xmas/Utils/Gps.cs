using System;
using System.Device.Location;
using org.meet4xmas.wire;

namespace Meet4Xmas
{
    public partial class Gps
    {
        public static void NewFromGps(Action<Location> cb)
        {
            Gps l = new Gps();
            l.FromGps(cb);
        }

        private Gps() { }

        private void FromGps(Action<Location> cb)
        {
            this.callback = cb;
            if (!((bool)Settings.AllowUsingLocation)) {
                callback.Invoke(null);
            } else {
                watcher = new GeoCoordinateWatcher(GeoPositionAccuracy.Default); // using high accuracy
                watcher.MovementThreshold = 20; // use MovementThreshold to ignore noise in the signal
                watcher.StatusChanged += new EventHandler<GeoPositionStatusChangedEventArgs>(watcher_StatusChanged);
                watcher.PositionChanged += new EventHandler<GeoPositionChangedEventArgs<GeoCoordinate>>(watcher_PositionChanged);
                watcher.Start();
            }
        }

        public void watcher_StatusChanged(object sender, GeoPositionStatusChangedEventArgs e)
        {
            switch (e.Status)
            {
                case GeoPositionStatus.Disabled:
                    watcher.Stop();
                    if (watcher.Permission == GeoPositionPermission.Denied)
                    {
                        callback.Invoke(null);
                    }
                    else
                    {
                        callback.Invoke(new Location(0.00, 0.00));
                    }
                    break;
                case GeoPositionStatus.Initializing:
                    break;
                case GeoPositionStatus.NoData:
                    break;
                case GeoPositionStatus.Ready:
                    break;
            }
        }

        void watcher_PositionChanged(object sender, GeoPositionChangedEventArgs<GeoCoordinate> e)
        {
            watcher.Stop();
            callback.Invoke(new Location(e.Position.Location.Longitude, e.Position.Location.Latitude));
        }

        private GeoCoordinateWatcher watcher;
        private Action<Location> callback;
    }
}
