using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FPSSETTER : MonoBehaviour
{
    public int fps = 60;

    public int _vsync = 1;
    public int vsync
    {
        get { return _vsync; }

        set
        {
            _vsync = value;
            QualitySettings.vSyncCount = _vsync;
        }

    }

    private void Start()
    {
        Application.targetFrameRate = fps;
        QualitySettings.vSyncCount = vsync;
    }
}
