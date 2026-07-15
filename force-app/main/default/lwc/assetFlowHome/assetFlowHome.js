import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class AssetFlowHome extends NavigationMixin(LightningElement) {

    openEmployeeDashboard() {

        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Employee_Dashboard'
            }
        });

    }

    openManagerDashboard() {

        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Manager_Dashboard'
            }
        });

    }

    openAdminDashboard() {

        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Admin_Dashboard'
            }
        });

    }

}