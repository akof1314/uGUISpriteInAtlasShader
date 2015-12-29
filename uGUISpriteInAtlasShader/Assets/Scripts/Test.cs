using UnityEngine;
using System.Collections;
using Effect;

public class Test : MonoBehaviour
{

    public UIImageTwistEffect effect;

    public void DoEffect()
    {
        if (effect)
        {
            effect.StartTwist();
        }
    }
}
