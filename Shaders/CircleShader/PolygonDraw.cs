using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PolygonDraw : MonoBehaviour
{
    public List <Element> CircleElements = new List<Element>();
    [System.Serializable]
    public class Element
    {
        [Range(0,100)]
        public float index;
    }
    public int size = 1024;

    void Start()
    {
        float angle = 0, elementsSum = 0, anglePlus = 0, radius = size/2;
        for (int i = 0; i < CircleElements.Count; i++) elementsSum += CircleElements[i].index;
        for (int i = 0; i < CircleElements.Count; i++)
        {
            List <Vector2> PolygonPoints = new List<Vector2>();
            angle = (CircleElements[i].index / elementsSum) * 360;
            gameObject.AddComponent<PolygonCollider2D>().isTrigger = true;
            for (float a = anglePlus; a <= anglePlus + angle + 0.0001f; a += angle / 6 / (CircleElements.Count < 5 ? (6 / CircleElements.Count) : 1))
            {
                PolygonPoints.Add(new Vector2(radius * Mathf.Sin(a * Mathf.Deg2Rad), radius * Mathf.Cos(a * Mathf.Deg2Rad)));
            }
            anglePlus += angle;
            PolygonPoints.Add(new Vector2(0,0));
            gameObject.GetComponents<PolygonCollider2D>()[i].points = PolygonPoints.ToArray();
        }
    }
}