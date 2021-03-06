/*
 * MainJFrame.java
 *
 * Created on March 21, 2007, 12:38 AM
 */

package coreedit;

/**
 *
 * @author  alex
 */
public class MainJFrame extends javax.swing.JFrame {
    
    /** Creates new form MainJFrame */
    public MainJFrame() {
        initComponents();
    }
    
    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    // <editor-fold defaultstate="collapsed" desc=" Generated Code ">//GEN-BEGIN:initComponents
    private void initComponents() {
        jScrollPane1 = new javax.swing.JScrollPane();
        jEditorPane1 = new javax.swing.JEditorPane();
        jMainMenuBar = new javax.swing.JMenuBar();
        jFileMenu = new javax.swing.JMenu();
        jOpenItem = new javax.swing.JMenuItem();
        jSaveItem = new javax.swing.JMenuItem();
        jCloseItem = new javax.swing.JMenuItem();
        jSetupMenu = new javax.swing.JMenu();

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
        setTitle("CoreEdit");
        setName("MainJFrame");
        getAccessibleContext().setAccessibleDescription("A Simple Editor");
        jScrollPane1.setAutoscrolls(true);
        jScrollPane1.setDoubleBuffered(true);
        jScrollPane1.setViewport(null);
        jEditorPane1.setDoubleBuffered(true);
        jScrollPane1.setViewportView(jEditorPane1);

        jFileMenu.setLabel("File");
        jOpenItem.setText("Open...");
        jOpenItem.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jOpenItemActionPerformed(evt);
            }
        });

        jFileMenu.add(jOpenItem);

        jSaveItem.setText("Save...");
        jSaveItem.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jSaveItemActionPerformed(evt);
            }
        });

        jFileMenu.add(jSaveItem);

        jCloseItem.setText("Close");
        jCloseItem.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jCloseItemActionPerformed(evt);
            }
        });

        jFileMenu.add(jCloseItem);

        jMainMenuBar.add(jFileMenu);

        jSetupMenu.setText("Setup");
        jMainMenuBar.add(jSetupMenu);

        setJMenuBar(jMainMenuBar);

        org.jdesktop.layout.GroupLayout layout = new org.jdesktop.layout.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(jScrollPane1, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 983, Short.MAX_VALUE)
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(jScrollPane1, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 524, Short.MAX_VALUE)
        );
        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void jCloseItemActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jCloseItemActionPerformed
        System.exit(0);
    }//GEN-LAST:event_jCloseItemActionPerformed

    /** Opens a Save File Dialog */
    private void jSaveItemActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jSaveItemActionPerformed
            javax.swing.JFileChooser savefile = new javax.swing.JFileChooser();
            if ( savefile.showSaveDialog(this) == javax.swing.JFileChooser.APPROVE_OPTION) {
                if (savefile.getSelectedFile().canWrite()) {
                    try
                    {
                    }
                    catch (Exception e)
                    {
                        javax.swing.JOptionPane.showMessageDialog(this,e.getMessage(),"Exception",javax.swing.JOptionPane.ERROR_MESSAGE);    
                    }
                }
            }
    }//GEN-LAST:event_jSaveItemActionPerformed

    /** Opens a Open File Dialog */
    private void jOpenItemActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jOpenItemActionPerformed
        javax.swing.JFileChooser openfile = new javax.swing.JFileChooser();
        if ( openfile.showOpenDialog(this) == javax.swing.JFileChooser.APPROVE_OPTION) {
            if (openfile.getSelectedFile().canRead()){
                try
                {
                   currentFile = new FileHandler (openfile.getSelectedFile());
		   jEditorPane1.read(currentFile.getReader(),null);
                }
                catch(java.io.FileNotFoundException fnfe)
                {
                    javax.swing.JOptionPane.showMessageDialog(this,fnfe.getMessage(),"File Not Found Exception",javax.swing.JOptionPane.ERROR_MESSAGE);
                }
                catch(java.io.IOException ioe)
                {
                    javax.swing.JOptionPane.showMessageDialog(this,ioe.getMessage(),"I/O Exception",javax.swing.JOptionPane.ERROR_MESSAGE);
                }
            }
        }
    }//GEN-LAST:event_jOpenItemActionPerformed
       
    /**
     * @param args the command line arguments
     */
    public static void main(String args[]) {
        java.awt.EventQueue.invokeLater(new Runnable() {
            public void run() {
                new MainJFrame().setVisible(true);
            }
        });
    }
    
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JMenuItem jCloseItem;
    private javax.swing.JEditorPane jEditorPane1;
    private javax.swing.JMenu jFileMenu;
    private javax.swing.JMenuBar jMainMenuBar;
    private javax.swing.JMenuItem jOpenItem;
    private javax.swing.JMenuItem jSaveItem;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JMenu jSetupMenu;
    // End of variables declaration//GEN-END:variables

    private FileHandler currentFile;
}
