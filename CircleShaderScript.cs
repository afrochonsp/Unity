using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CircleShaderScript : MonoBehaviour
{
    [Tooltip("Размер первого массива должен соответствовать второму, после изменения размера нужно перезагрузить сцену")]
    public Color[] colors = new Color[100];
    [Range(0.0f, 1.0f)]
    [Tooltip("Размер первого массива должен соответствовать второму, после изменения размера нужно перезагрузить сцену")]
    public float[] indexes = new float[100];
    public Color frameColor;
    [Range(0.0f, 1.0f)]
    public float frameSize;
    public Color centerColor;
    [Range(0.0f, 1.0f)]
    public float centerSize;
    public Color borderColor;
    [Range(0.0f, 1.0f)]
    public float borderSize;
    public Color secondBorderColor;
    [Range(0.0f, 1.0f)]
    public float secondBorderSize;

    void OnValidate()
    {
        GetComponent<Image>().material.SetColorArray("_Colors", colors);
        GetComponent<Image>().material.SetInt("_ColorsCount", colors.Length);
        GetComponent<Image>().material.SetFloatArray("_Indexes", indexes);
        GetComponent<Image>().material.SetFloat("_FrameSize", frameSize);
        GetComponent<Image>().material.SetColor("_FrameColor", frameColor);
        GetComponent<Image>().material.SetFloat("_CenterSize", centerSize);
        GetComponent<Image>().material.SetColor("_CenterColor", centerColor);
        GetComponent<Image>().material.SetFloat("_BorderSize", borderSize);
        GetComponent<Image>().material.SetColor("_BorderColor", borderColor);
        GetComponent<Image>().material.SetFloat("_SecondBorderSize", secondBorderSize);
        GetComponent<Image>().material.SetColor("_SecondBorderColor", secondBorderColor);
        float indexesSum = 0;
        for (int i = 0; i < indexes.Length; i++)
        {
            indexesSum += indexes[i];
        }
        GetComponent<Image>().material.SetFloat("_IndexesSum", indexesSum);
        int realCount = 0;
        foreach(float index in indexes)
        {
            if(index != 0) realCount += 1;
        }
        GetComponent<Image>().material.SetInt("_RealCount", realCount);
    }
}
