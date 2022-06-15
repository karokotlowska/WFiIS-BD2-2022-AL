using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Xml.Linq;


namespace lab13
{
    public partial class Form1 : Form
    {

        private DataClasses1DataContext db;
        public Form1()
        {
            InitializeComponent();
            db = new DataClasses1DataContext();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            XNamespace nsp = "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";
            XNamespace ns = "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume";


            //zad1
            var query1 = db.Persons.Select(p => new { name = p.LastName, demographics = p.Demographics });

            var val = new List<String>();

            foreach (var d in query1)
            {
                var qry = from commutedistance in ((XElement)d.demographics).Descendants(nsp + "CommuteDistance")
                          select commutedistance.Value;

                foreach (var q in qry)
                {
                    char first = q[0];
                    char second = q[2];
                    if ((first == '1' && second == '2') || (first == '2' && second == '5'))
                    {
                        string res = d.name + " " + q + " ";
                        val.Add(res);
                    }
                }
            }



            //zad2
            var val2 = new List<string>();

            foreach (var d in query1)
            {

                XElement elem = d.demographics;

                var qry2 = from number in elem.Elements(nsp + "NumberCarsOwned")
                           where int.Parse(number.Value) > 2
                           select number.Value;


                foreach (var q in qry2)
                {
                    string res = d.name + " " + q + " ";
                    val2.Add(res);
                }                   
            }


            //zad3
            var query3 = db.JobCandidates.Select(j => new { resume = j.Resume });

            var val3 = new List<string>();

            foreach (var d in query3)
            {
                XElement resumeXml = d.resume;

                var qry2 = from add in resumeXml.Elements(ns + "Address")
                           select add;

                string result = qry2.First().Element(ns + "Addr.Street").Value + " : " + qry2.First().Element(ns + "Addr.Location").Element(ns + "Location").Element(ns + "Loc.City").Value + " : " + qry2.First().Element(ns + "Addr.Telephone").Element(ns + "Telephone").Element(ns + "Tel.Number").Value;
                    val3.Add(result);

            }

            dataGridView1.DataSource = val.ConvertAll(x => new { Value = x });
            dataGridView2.DataSource = val2.ConvertAll(x => new { Value = x });
            dataGridView3.DataSource = val3.ConvertAll(x => new { Value = x });
        }


    }
}
