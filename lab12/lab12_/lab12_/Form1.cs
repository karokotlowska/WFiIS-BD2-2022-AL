using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace lab12_
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
            var query = from w in db.lab12_views select w;



            //zad2
            var query2 = query.GroupBy(d => new { d.DeparmentName })
                .Select(d => new { DeparmentName = d.Key.DeparmentName, maxSalary = d.Max(row => row.Rate) })
                .OrderByDescending(maxSalary => maxSalary.maxSalary);
            dataGridView2.DataSource = query2;


            //zad3
            var query3 = query.GroupBy(v => new { v.DeparmentName })
                .Select(v => new { DeparmentName = v.Key.DeparmentName, Rate = v.Max(row => row.Rate) })
                .Join(query, row => new { row.DeparmentName, row.Rate }, t => new { t.DeparmentName, t.Rate }, (r, l) => new { departmentName = r.DeparmentName, employeeName = l.Name, rate = r.Rate })
                .OrderByDescending(row => row.rate);
            dataGridView3.DataSource = query3;


            //zad4
            var query4 = query.Select(d => new { name = d.Name, d.DeparmentName })
                .Except(query.Join(db.SalesPersons, b => b.BusinessEntityID, b1 => b1.BusinessEntityID, (b, b1) => new { name = b.Name, DeparmentName = b.DeparmentName }))
                .OrderBy(DepartmentName => DepartmentName.DeparmentName);
            dataGridView4.DataSource = query4;


        }
    }
}
